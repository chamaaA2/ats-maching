package com.ust.match.utils;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.events.OrderCancelled;
import com.ust.groupa.domain.entities.instrument.order.events.OrderExecuted;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.groupa.domain.enums.OrderStatus;
import com.ust.groupa.domain.enums.TimeInForce;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.service.core.EvtContext;
import com.ustack.types.Timestamp;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

public class MatchUtils {
    public static List<BookOrder> separateOrders(Order order) {
        List<BookOrder> list = new ArrayList<>();
        int remainingQty = order.getOrderQty() - order.getCumulativeQty();
        int displayQty = Math.min(remainingQty, order.getDisplayQty());
        int hiddenQty = remainingQty - displayQty;
        if (displayQty > 0) {
            list.add(new BookOrder(order, displayQty, true));
        }
        if (hiddenQty > 0)
            list.add(new BookOrder(order, hiddenQty, false));
        return list;
    }

    private static Order pickAggressor(List<BookOrder> sellList, List<BookOrder> buyList) {
        if (sellList.isEmpty() || buyList.isEmpty())
            return null;
        BookOrder sellTop = sellList.get(0);
        BookOrder buyTop = buyList.get(0);
        if (sellTop.getTime() < buyTop.getTime())
            return buyTop.getOrder();
        else
            return sellTop.getOrder();
    }

    public static boolean isPriceMatch(OrderSide aggSide, BigDecimal constValue, BigDecimal aggValue) {
        if (aggSide.equals(OrderSide.SELL))
            return aggValue.compareTo(constValue) <= 0;
        else
            return aggValue.compareTo(constValue) >= 0;
    }

    public static boolean checkWithinNbbo(OrderSide aggSide, BigDecimal constValue, MDQuote quote) {
        if (aggSide.equals(OrderSide.SELL))
            return constValue.compareTo(quote.getNbb()) > 0;
        else
            return constValue.compareTo(quote.getNbo()) < 0;
    }

    public static void cancelOrdersAfterTrade(EvtContext<Instrument> context) {
        Timestamp time = context.currentTimestamp();
        context.getActiveEntitySet(Order.class).stream().filter(order -> order.getTif().in(TimeInForce.FOK, TimeInForce.IOC) || order.getMinimumQty() > 0)
                .forEach(order -> context.applyEvent(Order.class, order.getOrderId(),
                        new OrderCancelled(order.getOrderId(), order.getSymbol(), "Order Book cancelled", time)));
    }

    public static boolean printTrades(EvtContext<Instrument> context, Order incomingOrder, List<BookOrder> sellList, List<BookOrder> buyList) {
        boolean aggressorWorkDone = false;
        if (context.getEntity(Instrument.class, context.getRootId()).map(instrument -> instrument.isSymbolHalted()).get())
            return aggressorWorkDone;
        MDQuote quote = context.getEntity(MDQuote.class, context.getRootId())
                .orElseThrow(() -> GroupaErrorCodeException.MDQUOTE_DOES_NOT_EXIST(err -> err.setSymbol(context.getRootId())));
        Order aggressor = pickAggressor(sellList, buyList);
        if (aggressor == null)
            return aggressorWorkDone;
        if (incomingOrder != null && !aggressor.getOrderId().equals(incomingOrder.getOrderId()))
            return aggressorWorkDone;
        List<BookOrder> constList = aggressor.getSide().equals(OrderSide.SELL) ? buyList : sellList;
        int cumQty;
        boolean isCompleted = false;
        BigDecimal lastPrice;
        while (!isCompleted) {
            if (constList.isEmpty())
                break;
            BookOrder nextOrder = constList.remove(0);
            aggressor = context.getEntity(Order.class, aggressor.getOrderId()).get();
            int aggRemQty = aggressor.getOrderQty() - aggressor.getCumulativeQty();
            if (aggRemQty == 0)
                break;
            if (aggRemQty > nextOrder.getQty()) {
                cumQty = nextOrder.getQty();
                lastPrice = nextOrder.getPrice();
                if (aggressor.getTif().equals(TimeInForce.FOK) || aggressor.getMinimumQty() > nextOrder.getQty())
                    break;
                if (!isPriceMatch(aggressor.getSide(), aggressor.getPrice(), nextOrder.getPrice()) || !checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.PFIL));
            } else if (aggRemQty == nextOrder.getQty()) {
                cumQty = nextOrder.getQty();
                lastPrice = nextOrder.getPrice();
                if (!isPriceMatch(aggressor.getSide(), aggressor.getPrice(), nextOrder.getPrice()) || !checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                aggressorWorkDone = true;
                isCompleted = true;
            } else {
                cumQty = aggRemQty;
                lastPrice = nextOrder.getPrice();
                if (!isPriceMatch(aggressor.getSide(), aggressor.getPrice(), nextOrder.getPrice()) || !checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.PFIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                aggressorWorkDone = true;
                isCompleted = true;
            }
        }
        return aggressorWorkDone;
    }
}

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
        if (order.getDisplayQty() > 0)
            list.add(new BookOrder(order, order.getDisplayQty(), true));
        if ((order.getOrderQty() - order.getDisplayQty()) > 0)
            list.add(new BookOrder(order, order.getOrderQty() - order.getDisplayQty(), false));
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

    public static boolean checkWithinNbbo(OrderSide aggSide, BigDecimal value, MDQuote quote) {
        if (aggSide.equals(OrderSide.SELL))
            return value.compareTo(quote.getNbb()) > 0;
        else
            return value.compareTo(quote.getNbo()) < 0;
    }

    public static void cancelOrdersAfterTrade(EvtContext<Instrument> context) {
        Timestamp time = context.currentTimestamp();
        context.getActiveEntitySet(Order.class).stream().filter(order -> order.getTif().in(TimeInForce.FOK, TimeInForce.IOC) || order.getMinimumQty() > 0)
                .forEach(order -> context.applyEvent(Order.class, order.getOrderId(),
                        new OrderCancelled(order.getOrderId(), order.getSymbol(), "Order Book cancelled", time)));
    }

    public static void printTrades(EvtContext<Instrument> context, Order incomingOrder, List<BookOrder> sellList, List<BookOrder> buyList) {
        MDQuote quote = context.getEntity(MDQuote.class, context.getRootId())
                .orElseThrow(() -> GroupaErrorCodeException.MDQUOTE_DOES_NOT_EXIST(err -> err.setSymbol(context.getRootId())));
        Order aggressor = pickAggressor(sellList, buyList);
        if (aggressor == null)
            return;
        if (incomingOrder != null && !aggressor.getOrderId().equals(incomingOrder.getOrderId()))
            return;
        List<BookOrder> aggList = aggressor.getSide().equals(OrderSide.SELL) ? buyList : sellList;
        int i = 0;
        int cumQty;
        boolean isCompleted = false;
        BigDecimal lastPrice;
        while (!isCompleted) {
            if(aggList.isEmpty())
                break;
            BookOrder nextOrder = aggList.remove(i);
            if (aggressor.getOrderQty() > nextOrder.getQty()) {
                cumQty = nextOrder.getQty();
                lastPrice = nextOrder.getPrice();
                if (aggressor.getTif().equals(TimeInForce.FOK) || aggressor.getMinimumQty() > nextOrder.getQty())
                    break;
                if (!checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.PFIL));
            } else if (aggressor.getOrderQty() == nextOrder.getQty()) {
                cumQty = nextOrder.getQty();
                lastPrice = nextOrder.getPrice();
                if (!checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                isCompleted = true;
            } else {
                cumQty = aggressor.getOrderQty();
                lastPrice = nextOrder.getPrice();
                if (!checkWithinNbbo(aggressor.getSide(), lastPrice, quote))
                    break;
                context.applyEvent(Order.class, nextOrder.getOrder().getOrderId(), new OrderExecuted(nextOrder.getOrder().getOrderId()
                        , aggressor.getSymbol(), nextOrder.getOrder().getOrderQty(), cumQty, lastPrice, OrderStatus.PFIL));
                context.applyEvent(Order.class, aggressor.getOrderId(), new OrderExecuted(aggressor.getOrderId(), aggressor.getSymbol()
                        , aggressor.getOrderQty(), cumQty, lastPrice, OrderStatus.FIL));
                isCompleted = true;
            }
            i++;
        }
    }
}

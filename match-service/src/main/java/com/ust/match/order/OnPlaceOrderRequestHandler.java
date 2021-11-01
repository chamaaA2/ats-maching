package com.ust.match.order;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.commands.PlaceOrderRequest;
import com.ust.groupa.domain.entities.instrument.order.events.OrderAccepted;
import com.ust.groupa.domain.entities.instrument.order.events.OrderRejected;
import com.ust.groupa.domain.entities.instrument.orderbook.OrderBook;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.groupa.domain.enums.TimeInForce;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ust.match.utils.AtsUtils;
import com.ustack.common.TimeUtils;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;
import com.ustack.types.Timestamp;

import java.math.BigDecimal;

public class OnPlaceOrderRequestHandler extends EntityCommandHandler<Instrument, PlaceOrderRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, PlaceOrderRequest cmd) {
        boolean isMktOpen = cmdContext.getEntity(OrderBook.class, cmd.getSymbol()).map(orderBook -> orderBook.isIsMarketOpen())
                .orElseThrow(() -> GroupaErrorCodeException.ORDER_BOOK_DOES_NOT_EXIST(err -> err.setSymbol(cmd.getSymbol())));
        String error = null;
        String orderId = AtsUtils.getNewOrderId(cmdContext);
        Timestamp time = TimeUtils.getCurrentTimestamp();
        BigDecimal price = cmd.getPrice();
        switch (cmd.getOrderType()) {
            case PEG_MARKET:
            case PEG_PRIMARY:
            case PEG_MIDPT: {
                price = cmdContext.getEntity(MDQuote.class, cmd.getSymbol())
                        .map(quote -> getQuotePrice(cmd, quote))
                        .orElseThrow(() -> GroupaErrorCodeException.MDQUOTE_DOES_NOT_EXIST(err -> err.setSymbol(cmd.getSymbol())));
                if (!cmd.getTif().equals(TimeInForce.DAY))
                    error = "PEG Order tif type must be DAY";
                else if (!isMktOpen)
                    error = "Order type PEG orders couldn't trade in Market close session";
                else if (cmd.getExpireDates() > 0)
                    error = "Order type PEG, tif DAY orders haven't expireDates value";
                else if (cmd.getPrice().compareTo(BigDecimal.ZERO) > 0)
                    error = "Order type PEG Orders haven't initial set price";
                else if (cmd.getDisplayQty() != cmd.getOrderQty())
                    error = "Order type PEG Orders must be displayed.";
                break;
            }
            case LIMIT: {
                if (cmd.getTif().in(TimeInForce.FOK, TimeInForce.IOC) && !isMktOpen)
                    error = "Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session";
                else if (cmd.getExpireDates() > 0 && !cmd.getTif().in(TimeInForce.GTD))
                    error = "if tif doesn't GTD, orders haven't expireDates value";
                else if (cmd.getPrice().compareTo(BigDecimal.ZERO) <= 0)
                    error = "Price must Be positive values";
                break;
            }
            case MARKET: {
                if (cmd.getTif().notIn(TimeInForce.IOC, TimeInForce.FOK))
                    error = "MARKET Order tif type must be IOC, FOK";
                else if (!isMktOpen)
                    error = "Order type MARKET orders couldn't trade in Market close session";
                else if (cmd.getExpireDates() > 0)
                    error = "Order type MKT orders haven't expireDates value";
                else if (cmd.getPrice().compareTo(BigDecimal.ZERO) != 0)
                    error = "Order type MKT orders haven't price value";
                break;
            }
        }
        if (cmd.getMinimumQty() > cmd.getOrderQty())
            error = "Min Qty must be same or less than Order Qty";
        else if (cmd.getMinimumQty() > 0 && !cmd.getTif().equals(TimeInForce.IOC))
            error = "If orders have minimum qty, tif must be (IOC)";
        else if (cmdContext.getEntity(Instrument.class, cmdContext.getRootId()).map(instrument -> instrument.isSymbolHalted()).get())
            error = "Instrument halted.";
        else if (cmd.getDisplayQty() > cmd.getOrderQty())
            error = "Display Qty must be same or less than Order Qty";
        else if (cmd.getPrice().compareTo(BigDecimal.ZERO) < 0 || cmd.getOrderQty() < 0 || cmd.getMinimumQty() < 0 || cmd.getDisplayQty() < 0)
            error = "you have to use positive values";

        if (error != null) {
            OrderRejected rejected = new OrderRejected(orderId, cmd.getSymbol(), cmd.getOrderQty(), cmd.getSide()
                    , cmd.getOrderType(), time, cmd.getUserId(), cmd.getTif(), cmd.getDisplayQty(), cmd.getMinimumQty()
                    , price, cmd.getExpireDates(), error);
            cmdContext.applyEvent(Order.class, orderId, rejected);
            return GenericResponse.failed(error);
        } else {
            OrderAccepted accepted = new OrderAccepted(orderId, cmd.getSymbol(), cmd.getOrderQty(), cmd.getSide()
                    , cmd.getOrderType(), time, cmd.getUserId(), cmd.getTif(), cmd.getDisplayQty(), cmd.getMinimumQty()
                    , price, cmd.getExpireDates());
            cmdContext.applyEvent(Order.class, orderId, accepted);
            return GenericResponse.success(orderId);
        }
    }

    private BigDecimal getQuotePrice(PlaceOrderRequest cmd, MDQuote quote) {
        BigDecimal price = BigDecimal.ZERO;
        switch (cmd.getOrderType()) {
            case PEG_PRIMARY: {
                if (cmd.getSide().equals(OrderSide.SELL))
                    price = quote.getNbo();
                else
                    price = quote.getNbb();
                break;
            }
            case PEG_MARKET: {
                if (cmd.getSide().equals(OrderSide.BUY))
                    price = quote.getNbo();
                else
                    price = quote.getNbb();
                break;
            }
            case PEG_MIDPT: {
                price = quote.getNbo().add(quote.getNbb()).divide(new BigDecimal(2));
                break;
            }
        }
        return price.setScale(2);
    }
}

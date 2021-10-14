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
                        .map(quote -> cmd.getSide().equals(OrderSide.SELL) ? quote.getNbo() : quote.getNbb())
                        .orElseThrow(() -> GroupaErrorCodeException.ORDER_BOOK_DOES_NOT_EXIST(err -> err.setSymbol(cmd.getSymbol())));
                if (!cmd.getTif().equals(TimeInForce.DAY))
                    error = "PEG Order tif type must be DAY";
                else if (!isMktOpen)
                    error = "Order type PEG orders couldn't trade in Market close session";
                break;
            }
            case LIMIT: {
                if (cmd.getTif().in(TimeInForce.FOK, TimeInForce.IOC) && !isMktOpen)
                    error = "Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session";
                break;
            }
            case MARKET: {
                if (cmd.getTif().notIn(TimeInForce.DAY, TimeInForce.IOC, TimeInForce.FOK))
                    error = "MARKET Order tif type must be DAY, IOC, FOK";
                else if (!isMktOpen)
                    error = "Order type MARKET orders couldn't trade in Market close session";
                break;
            }
        }
        if (error != null) {
            OrderRejected rejected = new OrderRejected(orderId, cmd.getSymbol(), cmd.getOrderQty(), cmd.getSide()
                    , cmd.getOrderType(), time, cmd.getUserId(), cmd.getTif(), cmd.getDisplayQty(), cmd.getMinimumQty()
                    , price, cmd.getExpireDate(), error);
            cmdContext.applyEvent(Order.class, orderId, rejected);
            return GenericResponse.failed(orderId);
        } else {
            OrderAccepted accepted = new OrderAccepted(orderId, cmd.getSymbol(), cmd.getOrderQty(), cmd.getSide()
                    , cmd.getOrderType(), time, cmd.getUserId(), cmd.getTif(), cmd.getDisplayQty(), cmd.getMinimumQty()
                    , price, cmd.getExpireDate());
            cmdContext.applyEvent(Order.class, orderId, accepted);
            return GenericResponse.success(orderId);
        }
    }
}
package com.ust.match.orderBook;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.events.OrderExpired;
import com.ust.groupa.domain.entities.instrument.orderbook.events.MktClosed;
import com.ust.groupa.domain.enums.OrderType;
import com.ust.groupa.domain.enums.TimeInForce;
import com.ustack.common.TimeUtils;
import com.ustack.service.core.EntityEventHandler;
import com.ustack.service.core.EvtContext;
import com.ustack.types.Timestamp;


public class OnMktClosed extends EntityEventHandler<Instrument, MktClosed> {

    @Override
    public void onEvent(EvtContext<Instrument> evtContext, MktClosed event) {
        Timestamp expTime = TimeUtils.getCurrentTimestamp();
        evtContext.getActiveEntitySet(Order.class).stream()
                .filter(order -> !(order.getOrderType().equals(OrderType.LIMIT) && order.getTif().equals(TimeInForce.GTD)))
                .forEach(entity -> {
                    OrderExpired expired = new OrderExpired(entity.getOrderId(),entity.getSymbol(),"MKT_CLOSED",expTime);
                    evtContext.applyEvent(Order.class, entity.getOrderId(), expired);
                });
    }
}
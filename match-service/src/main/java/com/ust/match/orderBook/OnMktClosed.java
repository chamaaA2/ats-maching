package com.ust.match.orderBook;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.events.OrderExpired;
import com.ust.groupa.domain.entities.instrument.orderbook.events.MktClosed;
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
                .filter(order -> checkExpire(order, expTime))
                .forEach(entity -> {
                    OrderExpired expired = new OrderExpired(entity.getOrderId(), entity.getSymbol(), "MKT_EXP_WITH_TIF", expTime);
                    evtContext.applyEvent(Order.class, entity.getOrderId(), expired);
                });
    }

    private boolean checkExpire(Order order, Timestamp time) {
        if (order.getTif().equals(TimeInForce.DAY) || (order.getTif().equals(TimeInForce.GTD)
                && order.getOrderTime().getDateTime().withTimeAtStartOfDay().compareTo(time.getDateTime().minusDays(order.getExpireDates()).withTimeAtStartOfDay()) < 0)) {
            return true;
        }
        return false;
    }
}

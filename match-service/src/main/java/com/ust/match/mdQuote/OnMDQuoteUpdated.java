package com.ust.match.mdQuote;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteUpdated;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.events.OrderRepriced;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.groupa.domain.enums.OrderType;
import com.ustack.service.core.EntityEventHandler;
import com.ustack.service.core.EvtContext;

import java.math.BigDecimal;


public class OnMDQuoteUpdated extends EntityEventHandler<Instrument, MDQuoteUpdated> {

    @Override
    public void onEvent(EvtContext<Instrument> evtContext, MDQuoteUpdated event) {
        evtContext.getActiveEntitySet(Order.class).stream().filter(order -> order.getOrderType().in(OrderType.PEG_MARKET
                , OrderType.PEG_MIDPT, OrderType.PEG_PRIMARY))
                .forEach(entity -> {
                    OrderRepriced repriced = new OrderRepriced(entity.getOrderId(), event.getSymbol(), getPrice(entity, event), event.getNbboTime());
                    evtContext.applyEvent(Order.class, entity.getOrderId(), repriced);
                });
    }

    private BigDecimal getPrice(Order entity, MDQuoteUpdated event) {
        BigDecimal lastPrice = BigDecimal.ZERO;
        switch (entity.getOrderType()) {
            case PEG_PRIMARY: {
                if (entity.getSide().equals(OrderSide.SELL))
                    lastPrice = event.getNbo();
                else
                    lastPrice = event.getNbb();
                break;
            }
            case PEG_MARKET: {
                if (entity.getSide().equals(OrderSide.BUY))
                    lastPrice = event.getNbo();
                else
                    lastPrice = event.getNbb();
                break;
            }
            case PEG_MIDPT: {
                lastPrice = event.getNbo().add(event.getNbb()).divide(new BigDecimal(2));
                break;
            }
        }
        return lastPrice.setScale(2);
    }
}
package com.ust.match.order;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.order.commands.CancelOrderRequest;
import com.ust.groupa.domain.entities.instrument.order.events.OrderCancelled;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.common.TimeUtils;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnCancelOrderRequest extends EntityCommandHandler<Instrument, CancelOrderRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, CancelOrderRequest cmd) {
        Optional<Order> entity = cmdContext.getEntity(Order.class, cmd.getOrderId());
        if (entity.isPresent())
            GroupaErrorCodeException.ORDER_DOES_NOT_EXIST(err ->err.setOrderId(cmd.getOrderId()));
        OrderCancelled cancelled = new OrderCancelled(cmd.getOrderId(),cmd.getSymbol(),cmd.getComment(), TimeUtils.getCurrentTimestamp());
        cmdContext.applyEvent(Order.class, cmd.getOrderId(), cancelled);
        return GenericResponse.success();
    }
}

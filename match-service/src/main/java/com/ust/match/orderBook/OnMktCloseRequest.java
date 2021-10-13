package com.ust.match.orderBook;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.orderbook.OrderBook;
import com.ust.groupa.domain.entities.instrument.orderbook.commands.MktCloseRequest;
import com.ust.groupa.domain.entities.instrument.orderbook.events.MktClosed;
import com.ust.groupa.domain.entities.instrument.orderbook.events.OrderBookCreated;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnMktCloseRequest extends EntityCommandHandler<Instrument, MktCloseRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, MktCloseRequest cmd) {
        Optional<OrderBook> orderBook = cmdContext.getEntity(OrderBook.class, cmd.getSymbol());
        if (!orderBook.isPresent())
            cmdContext.applyEvent(OrderBook.class,cmd.getSymbol(),new OrderBookCreated(cmd.getSymbol()));
        MktClosed closed = new MktClosed(cmd.getSymbol(),cmd.getDate(),cmd.getTime());
        cmdContext.applyEvent(OrderBook.class, cmd.getSymbol(), closed);
        return GenericResponse.success();
    }
}
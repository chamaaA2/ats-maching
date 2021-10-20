package com.ust.match.orderBook;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.orderbook.events.MktOpened;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.match.utils.BookOrder;
import com.ust.match.utils.MatchUtils;
import com.ustack.service.core.EntityEventHandler;
import com.ustack.service.core.EvtContext;

import java.util.Collections;
import java.util.LinkedList;
import java.util.List;
import java.util.stream.Collectors;

public class OnMktOpened extends EntityEventHandler<Instrument, MktOpened> {
    List<BookOrder> buyOrderList = new LinkedList<>();
    List<BookOrder> sellOrderList = new LinkedList<>();

    @Override
    public void onEvent(EvtContext<Instrument> evtContext, MktOpened event) {
        loadOrders(evtContext);
        sortOrderBook();
        MatchUtils.printTrades(evtContext, null, sellOrderList, buyOrderList);
        MatchUtils.expireOrders(evtContext);
    }

    public void loadOrders(EvtContext<Instrument> context) {
        sellOrderList = context.getActiveEntitySet(Order.class).stream().filter(order -> order.getSide()
                .equals(OrderSide.SELL)).flatMap(order -> MatchUtils.separateOrders(order).stream()).collect(Collectors.toList());
        buyOrderList = context.getActiveEntitySet(Order.class).stream().filter(order -> order.getSide()
                .equals(OrderSide.BUY)).flatMap(order -> MatchUtils.separateOrders(order).stream()).collect(Collectors.toList());
    }
    private void sortOrderBook() {
        Collections.sort(buyOrderList);
        Collections.sort(sellOrderList);
        Collections.reverse(buyOrderList);
    }
}
package com.ust.match.query;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.orderbook.queries.GetMatchingOrderBook;
import com.ust.groupa.domain.enums.OrderSide;
import com.ustack.service.core.EntityQueryHandler;
import com.ustack.service.core.QueryContext;
import com.ustack.service.core.response.GenericResponse;
import org.reactivestreams.Publisher;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class GetMatchingOrderBookHandler extends EntityQueryHandler<Instrument, GetMatchingOrderBook, GenericResponse> {

    @Override
    public Publisher<GenericResponse> execute(QueryContext<Instrument> queryContext, GetMatchingOrderBook getMatchingOrderBook) {
        List<Order> sellList = queryContext.getActiveEntitySet(Order.class).stream()
                .filter(order -> order.getSide().equals(OrderSide.SELL)).collect(Collectors.toList());
        List<Order> buyList = queryContext.getActiveEntitySet(Order.class).stream()
                .filter(order -> order.getSide().equals(OrderSide.BUY)).collect(Collectors.toList());
        Map<String, Object> data = new HashMap<>();
        data.put("sellList", sellList);
        data.put("buyList", buyList);
        return GenericResponse.success(data).toMono();
    }
}

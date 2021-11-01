package com.ust.match.query;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.entities.instrument.orderbook.queries.GetMatchingOrderBook;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.groupa.domain.enums.OrderType;
import com.ustack.service.core.EntityQueryHandler;
import com.ustack.service.core.QueryContext;
import com.ustack.service.core.response.GenericResponse;
import org.reactivestreams.Publisher;
import reactor.core.publisher.Flux;

import java.math.BigDecimal;
import java.time.Duration;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;

public class GetMatchingOrderBookHandler extends EntityQueryHandler<Instrument, GetMatchingOrderBook, GenericResponse> {

    @Override
    public Publisher<GenericResponse> execute(QueryContext<Instrument> queryContext, GetMatchingOrderBook getMatchingOrderBook) {
        return Flux.interval(Duration.ofSeconds(1)).map(val -> GenericResponse.success(getOrderBook(queryContext)));
    }

    public List<Order> getOrderBook(QueryContext<Instrument> queryContext) {
        List<Order> sellList = queryContext.getActiveEntitySet(Order.class).stream()
                .filter(order -> order.getSide().equals(OrderSide.SELL))
                .sorted(Comparator.comparing(this::checkOrderTypeSort).thenComparing(this::checkSideAndPriceSort))
                .collect(Collectors.toList());
        List<Order> buyList = queryContext.getActiveEntitySet(Order.class).stream()
                .filter(order -> order.getSide().equals(OrderSide.BUY))
                .sorted(Comparator.comparing(this::checkOrderTypeSort).thenComparing(this::checkSideAndPriceSort))
                .collect(Collectors.toList());
        sellList.addAll(buyList);
        return sellList;
    }

    public BigDecimal checkSideAndPriceSort(Order o) {
        if (o.getSide().equals(OrderSide.SELL))
            return o.getPrice();
        else
            return o.getPrice().negate();
    }

    public int checkOrderTypeSort(Order o) {
        return o.getOrderType().equals(OrderType.MARKET) ? -1 : 0;
    }

}

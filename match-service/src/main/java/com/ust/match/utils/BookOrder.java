package com.ust.match.utils;

import com.ust.groupa.domain.entities.instrument.order.Order;
import com.ust.groupa.domain.enums.OrderSide;
import com.ust.groupa.domain.enums.OrderType;
import org.jetbrains.annotations.NotNull;

import java.math.BigDecimal;
import java.util.Comparator;

public class BookOrder implements Comparable<BookOrder> {
    Order order;
    BigDecimal price;
    int qty;
    boolean isDisplayQty;
    long time;

    public BookOrder(Order odr, int qty, boolean isDisplayQty) {
        order = odr;
        price = odr.getPrice();
        this.isDisplayQty = isDisplayQty;
        this.qty = qty;
        time = odr.getOrderTime().getMillis();
    }

    public int getQty() {
        return qty;
    }

    public BigDecimal getPrice() {
        return price;
    }

    public boolean isDisplayQty() {
        return isDisplayQty;
    }

    public Order getOrder() {
        return order;
    }

    public long getTime() {
        return time;
    }

    @Override
    public int compareTo(@NotNull BookOrder o) {
        return Comparator.comparing(this::checkOrderTypeSort)
                .thenComparing(this::checkSideAndPriceSort)
                .thenComparing(BookOrder::isDisplayQty)
                .thenComparingLong(BookOrder::getTime)
                .compare(this, o);
    }

    public BigDecimal checkSideAndPriceSort(BookOrder o) {
        if(o.getOrder().getSide().equals(OrderSide.SELL))
            return o.getPrice();
        else
            return o.getPrice().negate();
    }

    public int checkOrderTypeSort(BookOrder o) {
        return o.getOrder().getOrderType().equals(OrderType.MARKET) ? -1 : 0;
    }
}
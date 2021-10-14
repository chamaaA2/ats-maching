package com.ust.match.utils;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ustack.common.Base64Utils;
import com.ustack.service.core.EntityContext;

public class AtsUtils {
    private AtsUtils() {
    }

    public static String getNewOrderId(EntityContext<Instrument> context) {
        long execId = context.getCounter("orderId").getNext();

        String encode = Base64Utils.encode(execId, 10);
        return String.format("%s-%s", "Of", encode);
    }
}
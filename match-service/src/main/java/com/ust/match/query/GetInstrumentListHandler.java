package com.ust.match.query;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.orderbook.queries.GetInstrumentList;
import com.ustack.service.core.EntityQueryHandler;
import com.ustack.service.core.QueryContext;
import com.ustack.service.core.response.GenericResponse;
import org.reactivestreams.Publisher;


public class GetInstrumentListHandler extends EntityQueryHandler<Instrument, GetInstrumentList, GenericResponse> {

    @Override
    public Publisher<GenericResponse> execute(QueryContext<Instrument> queryContext, GetInstrumentList cmd) {
        return queryContext.query("select xjson->>'symbol' as symbol from entity where xmsgtype ='com.ust.groupa.domain.entities.instrument.Instrument'")
                .collectList().map(GenericResponse::success);
    }
}

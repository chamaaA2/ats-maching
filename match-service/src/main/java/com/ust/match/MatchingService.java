package com.ust.match;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.match.Instrument.OnInstrumentCreateRequest;
import com.ust.match.Instrument.OnInstrumentHaltRequest;
import com.ust.match.Instrument.OnInstrumentResumeRequest;
import com.ust.match.mdQuote.OnMDQuoteUpdated;
import com.ust.match.mdQuote.OnTickerQuoteUpdatedHandler;
import com.ust.match.order.OnCancelOrderRequest;
import com.ust.match.order.OnPlaceOrderRequestHandler;
import com.ust.match.orderBook.OnMktCloseRequest;
import com.ust.match.orderBook.OnMktClosed;
import com.ust.match.orderBook.OnMktOpenRequest;
import com.ustack.common.Injector;
import com.ustack.service.ServiceProvider;

public class MatchingService extends ServiceProvider<Instrument> {

    public MatchingService(Injector injector) {
        super(injector);
        registerCmdHandler(OnInstrumentCreateRequest.class);
        registerCmdHandler(OnInstrumentHaltRequest.class);
        registerCmdHandler(OnInstrumentResumeRequest.class);

        registerEvtHandler(OnTickerQuoteUpdatedHandler.class);
        registerEvtHandler(OnMDQuoteUpdated.class);

        registerCmdHandler(OnCancelOrderRequest.class);
        registerCmdHandler(OnPlaceOrderRequestHandler.class);

        registerCmdHandler(OnMktCloseRequest.class);
        registerCmdHandler(OnMktOpenRequest.class);
        registerEvtHandler(OnMktClosed.class);
    }
}
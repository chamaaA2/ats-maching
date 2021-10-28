package com.ust.match;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.match.Instrument.OnInstrumentCreateRequest;
import com.ust.match.Instrument.OnInstrumentHaltRequest;
import com.ust.match.Instrument.OnInstrumentResumeRequest;
import com.ust.match.mdQuote.MatchOrderOnMdQuoteUpdated;
import com.ust.match.mdQuote.OnMDQuoteUpdated;
import com.ust.match.mdQuote.OnTickerQuoteUpdateRequest;
import com.ust.match.order.OnCancelOrderRequest;
import com.ust.match.order.OnOrderAccepted;
import com.ust.match.order.OnPlaceOrderRequestHandler;
import com.ust.match.orderBook.OnMktCloseRequest;
import com.ust.match.orderBook.OnMktClosed;
import com.ust.match.orderBook.OnMktOpenRequest;
import com.ust.match.orderBook.OnMktOpened;
import com.ust.match.query.GetInstrumentListHandler;
import com.ust.match.query.GetMatchingOrderBookHandler;
import com.ustack.common.Injector;
import com.ustack.service.ServiceProvider;

public class MatchingService extends ServiceProvider<Instrument> {

    public MatchingService(Injector injector) {
        super(injector);
        registerCmdHandler(OnInstrumentCreateRequest.class);
        registerCmdHandler(OnInstrumentHaltRequest.class);
        registerCmdHandler(OnInstrumentResumeRequest.class);

        registerCmdHandler(OnTickerQuoteUpdateRequest.class);
        registerEvtHandler(OnMDQuoteUpdated.class,1);
        registerEvtHandler(MatchOrderOnMdQuoteUpdated.class,2);

        registerCmdHandler(OnCancelOrderRequest.class);
        registerCmdHandler(OnPlaceOrderRequestHandler.class);
        registerEvtHandler(OnOrderAccepted.class);

        registerCmdHandler(OnMktCloseRequest.class);
        registerCmdHandler(OnMktOpenRequest.class);
        registerEvtHandler(OnMktClosed.class);
        registerEvtHandler(OnMktOpened.class);

        registerQueryHandler(GetMatchingOrderBookHandler.class);
        registerQueryHandler(GetInstrumentListHandler.class);
    }
}

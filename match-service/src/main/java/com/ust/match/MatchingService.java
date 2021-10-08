package com.ust.match;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.match.Instrument.OnInstrumentCreateRequest;
import com.ust.match.Instrument.OnInstrumentHaltRequest;
import com.ust.match.Instrument.OnInstrumentResumeRequest;
import com.ust.match.mdQuote.OnMDRequest;
import com.ustack.common.Injector;
import com.ustack.service.ServiceProvider;

public class MatchingService extends ServiceProvider<Instrument> {

    public MatchingService(Injector injector) {
        super(injector);
        registerCmdHandler(OnInstrumentCreateRequest.class);
        registerCmdHandler(OnInstrumentHaltRequest.class);
        registerCmdHandler(OnInstrumentResumeRequest.class);
        registerCmdHandler(OnMDRequest.class);
    }
}
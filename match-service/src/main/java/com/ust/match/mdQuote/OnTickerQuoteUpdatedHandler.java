package com.ust.match.mdQuote;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteCreated;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteUpdated;
import com.ust.groupa.domain.entities.instrument.mdquote.events.TickerQuoteUpdated;
import com.ustack.service.core.EntityEventHandler;
import com.ustack.service.core.EvtContext;

import java.util.Optional;

public class OnTickerQuoteUpdatedHandler extends EntityEventHandler<Instrument, TickerQuoteUpdated> {

    @Override
    public void onEvent(EvtContext<Instrument> evtContext, TickerQuoteUpdated event) {

        Optional<MDQuote> quote = evtContext.getEntity(MDQuote.class, event.getSymbol());
        if (!quote.isPresent())
            evtContext.applyEvent(MDQuote.class, event.getSymbol(), new MDQuoteCreated(event.getSymbol()));
        evtContext.applyEvent(MDQuote.class, event.getSymbol(), new MDQuoteUpdated(event.getSymbol()
                , event.getNbo(), event.getNbb(), event.getNbboTime()));
    }
}

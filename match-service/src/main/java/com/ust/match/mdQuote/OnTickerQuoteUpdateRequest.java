package com.ust.match.mdQuote;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.mdquote.commands.TickerQuoteUpdateRequest;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteCreated;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteUpdated;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnTickerQuoteUpdateRequest extends EntityCommandHandler<Instrument, TickerQuoteUpdateRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, TickerQuoteUpdateRequest cmd) {
        Optional<MDQuote> quote = cmdContext.getEntity(MDQuote.class, cmd.getSymbol());
        if (!quote.isPresent())
            cmdContext.applyEvent(MDQuote.class, cmd.getSymbol(), new MDQuoteCreated(cmd.getSymbol()));
        cmdContext.applyEvent(MDQuote.class, cmd.getSymbol(), new MDQuoteUpdated(cmd.getSymbol()
                , cmd.getNbo(), cmd.getNbb(), cmd.getNbboTime()));
        return GenericResponse.success();
    }
}

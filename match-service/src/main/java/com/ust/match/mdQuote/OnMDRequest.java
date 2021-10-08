package com.ust.match.mdQuote;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.mdquote.MDQuote;
import com.ust.groupa.domain.entities.instrument.mdquote.commands.MDRequest;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteCreated;
import com.ust.groupa.domain.entities.instrument.mdquote.events.MDQuoteUpdated;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnMDRequest extends EntityCommandHandler<Instrument, MDRequest, GenericResponse> {

    @Override
    public GenericResponse execute(CmdContext<Instrument> cmdContext, MDRequest cmd) {
        Optional<MDQuote> quote = cmdContext.getEntity(MDQuote.class, cmd.getSymbol());
        if (!quote.isPresent())
            cmdContext.applyEvent(MDQuote.class, cmd.getSymbol(), new MDQuoteCreated(cmd.getSymbol()));
        MDQuoteUpdated updated = new MDQuoteUpdated(cmd.getSymbol(),cmd.getNbo(),cmd.getNbb(),cmd.getNbboTime());
        cmdContext.applyEvent(MDQuote.class, cmd.getSymbol(), updated);
        return GenericResponse.success();
    }
}
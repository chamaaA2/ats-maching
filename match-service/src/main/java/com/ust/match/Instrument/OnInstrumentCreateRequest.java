package com.ust.match.Instrument;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.commands.InstrumentCreateRequest;
import com.ust.groupa.domain.entities.instrument.events.InstrumentCreated;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnInstrumentCreateRequest extends EntityCommandHandler<Instrument, InstrumentCreateRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, InstrumentCreateRequest cmd) {
        Optional<Instrument> instrument = cmdContext.getEntity(Instrument.class, cmd.getSymbol());
        if (instrument.isPresent())
            GroupaErrorCodeException.INSTRUMENT_ALREADY_EXIST(err ->err.setSymbol(cmd.getSymbol()));
        InstrumentCreated created = new InstrumentCreated(cmd.getSymbol());
        cmdContext.applyEvent(Instrument.class, cmd.getSymbol(), created);
        return GenericResponse.success();
    }
}


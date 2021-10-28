package com.ust.match.Instrument;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.commands.InstrumentResumeRequest;
import com.ust.groupa.domain.entities.instrument.events.InstrumentResumed;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnInstrumentResumeRequest extends EntityCommandHandler<Instrument, InstrumentResumeRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, InstrumentResumeRequest cmd) {
        Optional<Instrument> instrument = cmdContext.getEntity(Instrument.class, cmd.getSymbol());
        if (!instrument.isPresent())
            return GenericResponse.failed("INSTRUMENT_DOES_NOT_EXIST");
        if (!instrument.map(entity -> entity.isSymbolHalted()).get())
            return GenericResponse.failed("INSTRUMENT_ALREADY_RESUMED");
        InstrumentResumed resumed = new InstrumentResumed(cmd.getSymbol(), cmd.getResumedReason());
        cmdContext.applyEvent(Instrument.class, cmd.getSymbol(), resumed);
        return GenericResponse.success();
    }
}

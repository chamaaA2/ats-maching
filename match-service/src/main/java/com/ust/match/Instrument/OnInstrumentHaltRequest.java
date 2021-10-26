package com.ust.match.Instrument;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.commands.InstrumentHaltRequest;
import com.ust.groupa.domain.entities.instrument.events.InstrumentHalted;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnInstrumentHaltRequest extends EntityCommandHandler<Instrument, InstrumentHaltRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, InstrumentHaltRequest cmd) {
        Optional<Instrument> instrument = cmdContext.getEntity(Instrument.class, cmd.getSymbol());
        if (!instrument.isPresent())
            return GenericResponse.failed("INSTRUMENT_DOES_NOT_EXIST");
        if (instrument.map(entity -> entity.isSymbolHalted()).get())
            return GenericResponse.failed("INSTRUMENT_ALREADY_HALTED");
        InstrumentHalted halted = new InstrumentHalted(cmd.getSymbol(), cmd.getHaltedReason());
        cmdContext.applyEvent(Instrument.class, cmd.getSymbol(), halted);
        return GenericResponse.success();
    }
}

package com.ust.match.Instrument;

import com.ust.groupa.domain.entities.instrument.Instrument;
import com.ust.groupa.domain.entities.instrument.commands.InstrumentHaltRequest;
import com.ust.groupa.domain.entities.instrument.events.InstrumentHalted;
import com.ust.groupa.domain.errors.GroupaErrorCodeException;
import com.ustack.service.core.CmdContext;
import com.ustack.service.core.Entity;
import com.ustack.service.core.EntityCommandHandler;
import com.ustack.service.core.response.GenericResponse;

import java.util.Optional;

public class OnInstrumentHaltRequest extends EntityCommandHandler<Instrument, InstrumentHaltRequest, GenericResponse> {

    public GenericResponse execute(CmdContext<Instrument> cmdContext, InstrumentHaltRequest cmd) {
        Optional<Instrument> instrument = cmdContext.getEntity(Instrument.class, cmd.getSymbol());
        if (!instrument.isPresent())
            GroupaErrorCodeException.INSTRUMENT_DOES_NOT_EXIST(err -> err.setSymbol(cmd.getSymbol()));
        if (instrument.map(entity -> entity.isSymbolHalted()).get())
            return GenericResponse.failed("Instrument already Halted :" + cmd.getSymbol());
        InstrumentHalted halted = new InstrumentHalted(cmd.getSymbol(), cmd.getHaltedReason());
        cmdContext.applyEvent(Instrument.class, cmd.getSymbol(), halted);
        return GenericResponse.success();
    }
}
Feature: on_instrument_halt_request

  Test OnInstrumentHaltRequest command handler

  entity: Instrument
  input command: InstrumentHaltRequest
  output event: InstrumentHalted
  functionality: Halt Instrument entity or generate response "Instrument entity already halted"

  Background:
    Given testing OnInstrumentHaltRequest functionality of MatchingService for root id APPL

    And system date is 2021/10/18 and time is 09:30:00

  Scenario: OnInstrumentHaltRequest_01
  Input command received
  Expected Behavior: Halt Instrument entity and generate output event

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | false        |

    When InstrumentHaltRequest received with input parameters
      | symbol | haltedReason      |
      | APPL   | REGULATORY_REASON |

    Then following events should be generated
      | InstrumentHalted |

    And InstrumentHalted event expected result like this
      | symbol | haltedReason      |
      | APPL   | REGULATORY_REASON |

    And Instrument entity state as follows
      | symbol | symbolHalted |
      | APPL   | true         |

  Scenario: OnInstrumentHaltRequest_02
  Input command received, but entity already halted
  Expected Behavior: No events generated, Create failure response

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | true         |

    When InstrumentHaltRequest received with input parameters
      | symbol | haltedReason      |
      | APPL   | REGULATORY_REASON |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_ALREADY_HALTED |

  Scenario: OnInstrumentHaltRequest_03
  Input command received, but Instrument entity does not exist
  Expected Behavior: No events generated, Create failure response

    When InstrumentHaltRequest received with input parameters
      | symbol | haltedReason      |
      | APPLE   | REGULATORY_REASON |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_DOES_NOT_EXIST |
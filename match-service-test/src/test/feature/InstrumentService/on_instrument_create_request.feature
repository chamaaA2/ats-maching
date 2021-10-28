Feature: on_instrument_create_request

  Test OnInstrumentCreateRequest command handler

  entity: Instrument
  input command: InstrumentCreateRequest
  output event: InstrumentCreated
  functionality: Create Instrument entity or generate response "Instrument entity already exists"

  Background:
    Given testing OnInstrumentCreateRequest functionality of MatchingService for root id APPL

    And system date is 2021/10/18 and time is 09:30:00

  Scenario: OnInstrumentCreateRequest_01
  Input command received
  Expected Behavior: Create Instrument entity and generate output event

    When InstrumentCreateRequest received with input parameters
      | symbol |
      | APPL   |

    Then following events should be generated
      | InstrumentCreated |

    And InstrumentCreated event expected result like this
      | symbol |
      | APPL   |

    And Instrument entity state as follows
      | symbol | symbolHalted |
      | APPL   | false        |

  Scenario: OnInstrumentCreateRequest_02
  Input command received, but entity already exist and it is not halted
  Expected Behavior: No events generated, Create failure response

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | false        |

    When InstrumentCreateRequest received with input parameters
      | symbol |
      | APPL   |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_ALREADY_EXISTS|

  Scenario: OnInstrumentCreateRequest_03
  Input command received, but entity already exist and it is halted
  Expected Behavior: No events generated, Create failure response

    When Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | true         |

    And InstrumentCreateRequest received with input parameters
      | symbol |
      | APPL   |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_ALREADY_EXISTS |
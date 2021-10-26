Feature: on_instrument_resume_request

  Test OnInstrumentResumeRequest command handler

  entity: Instrument
  input command: InstrumentResumeRequest
  output event: InstrumentResumed
  functionality: Resume Instrument entity or generate response "Instrument entity already Resumed"

  Background:
    Given testing OnInstrumentResumeRequest functionality of MatchingService for root id APPL

    And system date is 2021/10/18 and time is 09:30:00

  Scenario: OnInstrumentResumeRequest_01
  Input command received
  Expected Behavior: Resume Instrument entity and generate output event

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | true        |

    When InstrumentResumeRequest received with input parameters
      | symbol | resumedReason      |
      | APPL   | REGULATORY_REASON |

    Then following events should be generated
      | InstrumentResumed |

    And InstrumentResumed event expected result like this
      | symbol | resumedReason      |
      | APPL   | REGULATORY_REASON |

    And Instrument entity state as follows
      | symbol | symbolHalted |
      | APPL   | false         |

  Scenario: OnInstrumentResumeRequest_02
  Input command received, but entity already Resumed
  Expected Behavior: No events generated, Create failure response

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | false         |

    When InstrumentResumeRequest received with input parameters
      | symbol | resumedReason      |
      | APPL   | REGULATORY_REASON |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_ALREADY_RESUMED |

  Scenario: OnInstrumentResumeRequest_03
  Input command received, but Instrument entity does not exist
  Expected Behavior: No events generated, Create failure response

    When InstrumentResumeRequest received with input parameters
      | symbol | resumedReason      |
      | BAC   | REGULATORY_REASON |

    Then no events should be generated

    And expected response as follows
      | success | message                  |
      | false   | INSTRUMENT_DOES_NOT_EXIST |
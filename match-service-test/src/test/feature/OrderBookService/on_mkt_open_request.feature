Feature: on_mkt_open_request

  Test OnMktOpenRequest Event handler

  entity:
  input command: MktOpenRequest
  output event: OrderBookCreated, OrderBook, MktOpened
  functionality: OrderBook creation on MktOpenRequest

  Background:
    Given testing OnMktOpenRequest functionality of MatchingService for root id AAPL
    And system date is 2021/10/26 and time is 12:30:00

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

  Scenario: OnMktOpenRequest_01
  Input Command :Market Open Request with an available Order Book
  Expected Behaviour : Order Book state change as Market open

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    When MktOpenRequest received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MktOpened |

    And OrderBook entity state as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |


  Scenario: OnMktOpenRequest_02
  Input Command : Market Open Request without an Order Book
  Expected Behaviour : Order Book Created event should be generated

    When MktOpenRequest received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MktOpened | OrderBookCreated |




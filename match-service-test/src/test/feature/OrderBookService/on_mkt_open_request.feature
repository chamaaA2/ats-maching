Feature: on_mkt_open_request

  Test OnMktOpenRequest Event handler

  entity:
  input command: TickerQuoteUpdated
  output event: MDQuoteUpdated MDQuoteCreated
  functionality: Create or Update MDQuote Entity

  Background:
    Given testing OnMktOpenRequest functionality of MatchingService for root id AAPL
    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnMktOpenRequest_01
  Input Command :expire date 2021/10/27
  Expected Behaviour : Order Expired Entity should be generated

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
      | AAPL   | true        |

  Scenario: OnMktOpenRequest_02
  Input Command :expire date 2021/10/27
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    When MktOpenRequest received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MktOpened |

    And OrderBook entity state as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |
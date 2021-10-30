Feature: on_ticker_quote_updated_handler

  Test OnTickerQuoteUpdated Event handler

  entity: MDQuote
  input command: TickerQuoteUpdated
  output event: MDQuoteUpdated MDQuoteCreated
  functionality: Create or Update MDQuote Entity

  Background:
    Given testing OnTickerQuoteUpdateRequest functionality of MatchingService for root id AAPL

    And system date is 2021/10/26 and time is 12:30:00

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

  Scenario: OnTickerQuoteUpdateHandler_01

    When TickerQuoteUpdateRequest received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MDQuoteCreated | MDQuoteUpdated |

  Scenario: OnTickerQuoteUpdateHandler_02

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When TickerQuoteUpdateRequest received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MDQuoteUpdated |


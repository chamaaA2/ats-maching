Feature: match_order_on_md_quote_updated

  Test OnMatchOrderOnMdQuoteUpdated Event handler

  entity: MDQuote
  input command: MDQuoteUpdated
  output event: OrderExecuted
  functionality: OrderExecuted

  Background:
    Given testing MatchOrderOnMdQuoteUpdated functionality of MatchingService for root id AAPL

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |
      | Of-0000000002 | AAPL   | 15       | BUY  | MARKET      | NEW         | 0             | 15        | userId_02 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |
    And system date is 2021/10/26 and time is 12:30:00

  Scenario: MatchOrderOnMdQuoteUpdatedHandler_01
    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExecuted |

  Scenario: MatchOrderOnMdQuoteUpdated_02

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExecuted |
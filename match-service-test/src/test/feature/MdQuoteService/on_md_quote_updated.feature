Feature: on_md_quote_updated

  Test OnMDQuoteUpdated Event handler

  entity: MDQuote
  input command: MDQuoteUpdated
  output event: OrderRepriced
  functionality: OrderRepriced

  Background:
    Given testing OnMDQuoteUpdated functionality of MatchingService for root id AAPL


    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnMDQuoteUpdate_01

    Given Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDates |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | 1           |
      | Of-0000000002 | AAPL   | 10       | SELL | PEG_MARKET  | NEW         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | 1           |
      | Of-0000000003 | AAPL   | 10       | BUY  | PEG_MIDPT   | NEW         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | 1           |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRepriced |

    And Order entity state as follows
      | orderId       | symbol | price |
      | Of-0000000001 | AAPL   | 10.00 |
      | Of-0000000002 | AAPL   | 10.00 |
      | Of-0000000003 | AAPL   | 10.50 |


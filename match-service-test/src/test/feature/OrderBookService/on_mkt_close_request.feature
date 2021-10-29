Feature: on_mkt_close_request

  Test OnMktCloseRequest Event handler

  entity:
  input command: TickerQuoteUpdated
  output event: MDQuoteUpdated MDQuoteCreated
  functionality: Create or Update MDQuote Entity

  Background:
    Given testing OnMktCloseRequest functionality of MatchingService for root id AAPL
    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnMktCloseRequest_01
  Input Command :expire date 2021/10/27
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   |  true        |

    #And Order entity exist as follows
      #| orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      #| Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktCloseRequest received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MktClosed |

    And OrderBook entity state as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |
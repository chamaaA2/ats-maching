Feature: on_mkt_close_request

  Test OnMktCloseRequest Event handler

  entity:
  input command: MKT Closed Request
  output event: MKT closed
  functionality: Market close

  Background:
    Given testing OnMktCloseRequest functionality of MatchingService for root id AAPL
    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnMktCloseRequest_01
  Input Command :expire date 2021/10/27
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   |  true        |

    And Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:27:00')` | userId_1 | GTD | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:28:00')` | userId_2 | GTD | 10         | 0          | 10    | 0           |

    When MktCloseRequest received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | MktClosed |

    And OrderBook entity state as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |
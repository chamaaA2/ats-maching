Feature: on_mkt_opened

  Test OnMktOpened Event handler

  entity:
  input command: MktOpenRequest
  output event: OrderBookCreated, OrderBook, MktOpened
  functionality: OrderBook creation on MktOpenRequest

  Background:
    Given testing OnMktOpened functionality of MatchingService for root id APPL

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | false        |


  Scenario: on_mkt_opened_01

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | APPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | APPL   | 10  | 11  | `toEpoch('2021/10/18 09:25:00')` |

    And Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:27:00')` | userId_1 | GTD | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:28:00')` | userId_2 | GTD | 10         | 0          | 10    | 0           |

    And MktOpened received with these input parameters
      | symbol | date       | time                             |
      | APPL   | 2021/10/18 | `toEpoch('2021/10/18 09:29:00')` |

    Then following events should be generated
      | OrderExecuted |

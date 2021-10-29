Feature: on_mkt_opened

  Test OnMktOpened Event handler

  entity:
  input command: MktOpenRequest
  output event: OrderBookCreated, OrderBook, MktOpened
  functionality: OrderBook creation on MktOpenRequest

  Background:
    Given testing OnMktOpened functionality of MatchingService for root id AAPL

    And system date is 2021/10/26 and time is 12:30:00

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |


  Scenario: on_mkt_opened_01

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDates |
      | Of-0000000001 | AAPL   | 10       | BUY  | LIMIT     | NEW         | 0             | 10        | userId_01 | GTD | 10         | 0          | 0     | 2           |
      | Of-0000000002 | AAPL   | 10       | SELL | LIMIT     | NEW         | 0             | 10        | userId_01 | GTD | 10         | 0          | 0     | 2           |

    Then following events should be generated
      | OrderExecuted |


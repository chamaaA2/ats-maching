Feature: on_order_accepted

  Test OnOrderAccepted event handler

  entities : Order
  input event : OrderAccepted
  output events : OrderExecuted, OrderCancelled
  functionality : Trigger matching logic or initial cancellations

  Background:
    Given testing OnOrderAccepted functionality of MatchingService for root id APPL

    And system date is 2021/10/18 and time is 09:30:00

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | APPL   | 10  | 12  | `toEpoch('2021/10/18 09:30:00')` |

  Scenario: OnOrderAccepted_01

  Incoming order matcxhes to resting contra order (order book with one contra order)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 25       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0 |
      | order_2 | APPL   | 10       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10.5  | 0 |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_2 | APPL   | 10       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10.5  | 0 |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | PFIL        | 10      | 11      |
      | order_2 | FIL         | 10      | 11      |

    And Order entity state as follows
      | orderId | symbol |orderStatus | cumulativeQty |
      | order_1 | APPL |PFIL        | 10      |
      | order_2 | APPL |FIL         | 10      |

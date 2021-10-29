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

  Incoming order matches to resting contra order
  (incoming sell order fill, one contra order fill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0          |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0          |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_2 | APPL   | 40       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0          |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 40      | 11        |
      | order_2 | FIL         | 40      | 11       |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |
      | order_1 | FIL         | 40            |
      | order_2 | FIL         | 40            |
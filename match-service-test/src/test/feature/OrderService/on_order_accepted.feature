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

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | APPL   | false        |

  Scenario: OnOrderAccepted_01

  Incoming order matches to resting contra order
  (incoming sell order fill, one contra order fill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 40         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_2 | APPL   | 40       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 40      | 11        |
      | order_2 | FIL         | 40      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty | symbol |
      | order_1 | FIL         | 40            | APPL   |
      | order_2 | FIL         | 40            | APPL   |

  Scenario: OnOrderAccepted_02

  Incoming order matches to resting contra order
  (incoming sell order fill, one contra order pfill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 100      | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 100        | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_2 | APPL   | 40       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | PFIL        | 40      | 11        |
      | order_2 | FIL         | 40      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty | symbol |
      | order_1 | PFIL        | 40            | APPL   |
      | order_2 | FIL         | 40            | APPL   |

  Scenario: OnOrderAccepted_03_failed

  Incoming order matches to resting contra multiple orders
  (incoming sell order fill, one contra order fill, other pfill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 10       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 10         | 0          | 11    | 0           |
      | order_2 | APPL   | 100      | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 100        | 0          | 11    | 0           |
      | order_3 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_3 | APPL   | 40       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 10      | 11        |
      | order_2 | PFIL        | 30      | 11        |
      | order_3 | PFIL        | 10      | 11        |
      | order_3 | FIL         | 30      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty | symbol |
      | order_1 | FIL         | 10            | APPL   |
      | order_2 | PFIL        | 30            | APPL   |
      | order_3 | PFIL         | 10            | APPL   |
      | order_3 | FIL         | 40            | APPL   |

  Scenario: OnOrderAccepted_04_failed

  Incoming order matches to resting contra multiple orders
  (incoming sell order fill, multiple contra orders fill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 10       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 10         | 0          | 11    | 0           |
      | order_2 | APPL   | 30       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 30         | 0          | 11    | 0           |
      | order_3 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_3 | APPL   | 40       | SELL | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 10      | 11        |
      | order_2 | FIL         | 30      | 11        |
      | order_3 | PFIL         | 10      | 11        |
      | order_3 | FIL         | 30      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |symbol |
      | order_1 | FIL         | 10            |APPL   |
      | order_2 | FIL         | 30            |APPL   |
      | order_3 | FIL         | 40            |APPL   |

  Scenario: OnOrderAccepted_05

  Incoming order matches to resting contra order
  (incoming buy order pfill, one contra order fill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 15       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 15         | 0          | 10    | 0           |
      | order_2 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 11    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_2 | APPL   | 40       | BUY  | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 11    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 15      | 10        |
      | order_2 | PFIL        | 15      | 10        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |symbol |
      | order_1 | FIL         | 15            |APPL   |
      | order_2 | PFIL        | 15            |APPL   |

  Scenario: OnOrderAccepted_06

  Incoming order matches to resting contra multiple orders
  (incoming buy order pfill, multiple contra orders fill, normal mkt)
  Expected Behaviour: OrderExecuted event generated

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 10       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 10         | 0          | 11    | 0           |
      | order_2 | APPL   | 5        | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 5          | 0          | 11    | 0           |
      | order_3 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When OrderAccepted received with these input parameters
      | orderId | symbol | orderQty | side | orderType | orderAcceptedTime                | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_3 | APPL   | 40       | BUY  | LIMIT     | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 10      | 11        |
      | order_2 | FIL         | 5       | 11        |
      | order_3 | PFIL        | 10      | 11        |
      | order_3 | PFIL        | 5       | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |
      | order_1 | FIL         | 10            |
      | order_2 | FIL         | 5             |
      | order_3 | PFIL        | 15            |

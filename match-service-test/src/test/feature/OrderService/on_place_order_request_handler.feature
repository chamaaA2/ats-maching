Feature: on_place_order_request_handler

  Test OnPlaceOrderRequestHandler command handler

  entity : Order
  input command : PlaceOrderRequest
  output event : OrderAccepted, OrderRejected
  functionality : Accept or Reject order

  Background:
    Given testing OnPlaceOrderRequestHandler functionality of MatchingService for root id AAPL

    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnPlaceOrderRequestHandler_01
  Input command : PEG order entered with a TIF type GTD
  Expected Behavior : Order Reject Entity should be generated
  Reason: PEG orders can be only day

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType   | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | GTD | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason            |
      | PEG Order tif type must be DAY |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_02
  Input command : PEG order entered with on a Market close session
  Expected Behavior : Order Reject Entity should be generated
  Reason: PEG order can be only entered in Market open session

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType   | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                          |
      | Order type PEG orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_03
  Input command : PEG order entered with a TIF day and a expire date
  Expected Behavior : Order Reject Entity should be generated
  Reason: PEG order can be only day and TIF type DAY cannot have expire date

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType   | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 10         | 0          | 0     | 1           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                      |
      | Order type PEG, tif DAY orders haven't expireDates value |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_04
  Input command : Limit Order entered with TIF type FOK on Market Close session
  Expected Behavior : Order Reject Entity should be generated
  Reason: Limit FOK orders can be traded only on Market open session

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                                      |
      | Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_05
  Input command : Limit Order entered with TIF type IOC on Market Close session
  Expected Behavior : Order Reject Entity should be generated
  Reason: Limit IOC orders can be traded only on Market open session

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                                      |
      | Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_06
  Input command : MARKET Order entered with TIF type DAY
  Expected Behavior : Order Reject Entity should be generated
  Reason: Limit IOC orders can be traded only on Market open session

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | DAY | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                    |
      | MARKET Order tif type must be IOC, FOK |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_07
  Input command : MARKET Order entered in a Market close session
  Expected Behavior : Order Reject Entity should be generated
  Reason: MARKET orders can be only traded in Maket Open session

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                             |
      | Order type MARKET orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_08
  Input command : MARKET Order entered with an expire date
  Expected Behavior : Order Reject Entity should be generated
  Reason: MARKET orders cannot have an expire date

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 1           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                             |
      | Order type MKT orders haven't expireDates value |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_09
  Input command : MARKET Order entered with a price
  Expected Behavior : Order Reject Entity should be generated
  Reason: MARKET orders cannot have an user entered price

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 150   | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                       |
      | Order type MKT orders haven't price value |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |
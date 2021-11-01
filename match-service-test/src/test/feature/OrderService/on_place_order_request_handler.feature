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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 100   | 0           |

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
  Reason: Market order TIF type can be only IOC and FOK

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


  Scenario: OnPlaceOrderRequestHandler_10
  Input command : MARKET Order entered with a Min Quantity and TIF type FOK
  Expected Behavior : Order Reject Entity should be generated
  Reason: Min Quantity Orders TIF type must be IOC

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 7          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                           |
      | If orders have minimum qty, tif must be (IOC) |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |

  Scenario: OnPlaceOrderRequestHandler_11
  Input command : MARKET Order entered with a Min Quantity and TIF type DAY
  Expected Behavior : Order Reject Entity should be generated
  Reason: Min Quantity Orders TIF type must be IOC

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | DAY | 10         | 7          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                           |
      | If orders have minimum qty, tif must be (IOC) |


  Scenario: OnPlaceOrderRequestHandler_12
  Input command : MARKET Order entered to a Halted Instrument.
  Expected Behavior : Order Reject Entity should be generated
  Reason: Order cannot be entered to halted instrument

    Given Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | true         |

    And OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDates |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason |
      | Instrument halted.  |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_13
  Input command : PEG order entered with a TIF type DAY
  Expected Behavior : Order Accept Entity should be generated
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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 0          | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_14
  Input command : PEG order entered with on a Market open session
  Expected Behavior : Order Accept Entity should be generated
  Reason: PEG order can be only entered in Market open session

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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 0          | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_15
  Input command : PEG order entered with a TIF day and without expire date
  Expected Behavior : Order Accept Entity should be generated
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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 0          | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_16
  Input command : Limit Order entered with TIF type FOK on Market Open session
  Expected Behavior : Order Accept Entity should be generated
  Reason: Limit FOK orders can be traded only on Market open session

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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 100   | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_17
  Input command : Limit Order entered with TIF type IOC on Market Open session
  Expected Behavior : Order Accept Entity should be generated
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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 150   | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_18
  Input command : MARKET Order entered with TIF type FOK
  Expected Behavior : Order Accept Entity should be generated
  Reason: Market order TIF type can be only IOC and FOK

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_19
  Input command : MARKET Order entered with TIF type IOC
  Expected Behavior : Order Accept Entity should be generated
  Reason: Market order TIF type can be only IOC and FOK

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_20
  Input command : MARKET Order entered in a Market Open session
  Expected Behavior : Order Accept Entity should be generated
  Reason: MARKET orders can be only traded in Maket Open session

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_21
  Input command : MARKET Order entered without an expire date
  Expected Behavior : Order Accept Entity should be generated
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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_22
  Input command : MARKET Order entered without a price
  Expected Behavior : Order Accept should be generated
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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_23
  Input command : MARKET Order entered with a Min Quantity and TIF type IOC
  Expected Behavior : Order Accept Entity should be generated
  Reason: Min Quantity Orders TIF type must be IOC

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 10         | 7          | 0     | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |

##########
  Scenario: OnPlaceOrderRequestHandler_24
  Input command : PEG Order entered with a price
  Expected Behavior : Order Accept should be generated
  Reason: PEG orders cannot have an user entered price

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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 10         | 0          | 150   | 0           |

    Then following events should be generated
      | OrderRejected |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_25
  Input command : MARKET Order entered with a Minimum Quantity higher than Order Quantity
  Expected Behavior : Order Reject Entity should be generated
  Reason:  Minimum Quantity cannot be higher than Order Quantity

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 0          | 11         | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_26
  Input command : MARKET Order entered with a Display Quantity higher than Order Quantity
  Expected Behavior : Order Reject Entity should be generated
  Reason: Display Quantity cannot be higher than Order Quantity

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 15         | 7          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_27
  Input command : Limit Order entered without a Price
  Expected Behavior : Order Accept Entity should be generated
  Reason: Limit cannot be entered without a price

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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |

  ###########

  Scenario: OnPlaceOrderRequestHandler_28
  Input command : Limit Order entered with TIF type DAY on Market Close session
  Expected Behavior : Order Accept Entity should be generated
  Reason: Limit DAY orders can be traded only on Market open session

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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | DAY | 10         | 0          | 100   | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_29
  Input command : Limit Order entered with TIF type DAY on Market Close session
  Expected Behavior : Order Accept Entity should be generated
  Reason: Limit DAY orders can be traded only on Market open session

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
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | GTD | 10         | 0          | 100   | 0           |

    Then following events should be generated
      | OrderAccepted |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_30
  Input command : PEG order entered with a TIF type FOK
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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | FOK | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason            |
      | PEG Order tif type must be DAY |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_31
  Input command : PEG order entered with a TIF type IOC
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
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | IOC | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason            |
      | PEG Order tif type must be DAY |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_32
  Input command : MARKET Order entered with TIF type GTD
  Expected Behavior : Order Reject Entity should be generated
  Reason: Market order TIF type can be only IOC and FOK

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
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | GTD | 10         | 0          | 0     | 0           |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                    |
      | MARKET Order tif type must be IOC, FOK |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


Feature: on_place_order_request_handler

  Test OnPlaceOrderRequestHandler command handler

  entity : Order
  input command : PlaceOrderRequest
  output event : OrderAccepted, OrderRejected
  functionality : Accept or Reject order

  Background:
    Given testing OnPlaceOrderRequestHandler functionality of MatchingService for root id AAPL

    And system date is 2021/10/26 and time is 12:30:00

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |


  Scenario: OnPlaceOrderRequestHandler_01
  Input command received PEG order during market closed
  Expected Behavior : Order Reject Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType   | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                          |
      | Order type PEG orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |


  Scenario: OnPlaceOrderRequestHandler_02
  Input command received PEG order without TIF type DAY
  Expected Behavior : Order Reject Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType   | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | PEG_PRIMARY | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason            |
      | PEG Order tif type must be DAY |

    And Order entity state as follows
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |


  Scenario: OnPlaceOrderRequestHandler_03
  Input command received limit order with TIF type FOK in a market close session
  Expected Behavior : Order Reject Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                                      |
      | Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |


  Scenario: OnPlaceOrderRequestHandler_04
  Input command received limit order with TIF type IOC in a market close session
  Expected Behavior : Order Reject Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                                      |
      | Order tif (FOK, IOC) LIMIT orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |


  Scenario: OnPlaceOrderRequestHandler_05
  Input command received with MARKET order type in a market close session
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                                             |
      | Order type MARKET orders couldn't trade in Market close session |

    And Order entity state as follows
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |


  Scenario: OnPlaceOrderRequestHandler_06
  Input command received with MARKET order type in a market open session
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_08
  Input command received with MARKET order type with a TIF type GTD
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderRejectedReason                         | orderQty |
      | MARKET Order tif type must be DAY, IOC, FOK | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_09
  Input command received with MARKET order type with a TIF type FOK
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_10
  Input command received with MARKET order type with a TIF type IOC
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | MARKET    | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_11
  Input command received with LIMIT order type with a TIF type IOC on Market Close session
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_12
  Input command received with LIMIT order type with a TIF type FOK on Market Close session
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_13
  Input command received with LIMIT order type with a TIF type IOC on Market Open Session
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_14
  Input command received with LIMIT order type and with a TIF type FOK on Market Open Session
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_15
  Input command : Limit Order Type with a TIF type DAY on a Market Close session with a Display qty
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_16
  Input command : Limit Order Type with a TIF type DAY on a Market Close session without a Display qty
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | DAY | 0          | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_17
  Input command : Limit Order Type with a TIF type GTD on a Market Close session with a Display qty
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_18
  Input command : Limit Order Type with a TIF type GTD on a Market Close session without a Display qty
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | GTD | 0          | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_19
  Input command : Limit Order Type with a TIF type DAY on a Market Open session with a Display qty
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_20
  Input command : Limit Order Type with a TIF type DAY on a Market Open session without a Display qty
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | DAY | 0          | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


  Scenario: OnPlaceOrderRequestHandler_21
  Input command : Limit Order Type with a TIF type GTD on a Market Close session with a Display qty
  Expected Behavior : Order Accept Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | BUY  | LIMIT     | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderAccepted |

    And OrderAccepted event expected result like this
      | orderId       | symbol |
      | Of-0000000001 | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | NEW         |


  Scenario: OnPlaceOrderRequestHandler_22
  Input command : Limit Order Type with a TIF type GTD on a Market Open session without a Display qty
  Expected Behavior : Order Reject Entity should be created

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When PlaceOrderRequest received with these input parameters
      | symbol | orderQty | side | orderType | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | AAPL   | 10       | SELL | LIMIT     | userId_01 | GTD | 0          | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRejected |

    And OrderRejected event expected result like this
      | orderId       | orderQty |
      | Of-0000000001 | 10       |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |


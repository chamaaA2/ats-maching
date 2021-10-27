Feature: on_place_order_request_handler

  Test OnPlaceOrderRequestHandler command handler

  entity : Order
  input command : PlaceOrderRequest
  output event : OrderAccepted
  functionality : Accept or Reject order

  Background:
    Given testing OnPlaceOrderRequestHandler functionality of MatchingService for root id AAPL

    And system date is 2021/10/26 and time is 12:30:00

    And Instrument entity exist as follows
      | symbol | symbolHalted |
      | AAPL   | false        |

  Scenario: OnPlaceOrderRequestHandler_01
  Input command received PEG order during market closed
  Expected Behavior : Send an ERROR message

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



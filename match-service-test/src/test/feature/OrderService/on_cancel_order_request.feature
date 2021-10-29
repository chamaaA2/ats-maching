Feature: on_cancel_order_request

  Test OnCancelOrderRequest command handler

  entity : order
  input command : CancelOrderRequest
  output event : OrderCancelled
  functionality :   Cancel order

  Background:
    Given testing OnCancelOrderRequest functionality of MatchingService for root id AAPL


  Scenario: OnCancelOrderRequest_01
  Input command : Cancel Order Request
  Expected behavior : OrderCancelled entity should be generated

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000002 | AAPL   | 15       | BUY  | MARKET    | NEW         | 0             | 15        | userId_02 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When CancelOrderRequest received with these input parameters
      | symbol | orderId       | comment        |
      | AAPL   | Of-0000000002 | Not Interested |

    Then following events should be generated
      | OrderCancelled |

    And OrderCancelled event expected result like this
      | orderId       |
      | Of-0000000002 |

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000002 | AAPL   | CNC         |


  Scenario: OnCancelRequest_02
  Input command : Cancel Order Request for a PreFilled Order
  Expected beahvior : OrderCancelled entity should not be generated


    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | PFILL       | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When CancelOrderRequest received with these input parameters
      | symbol | orderId       | comment        |
      | AAPL   | Of-0000000001 | Not Interested |

    Then no events should be generated

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | PFILL       |


  Scenario: OnCancelRequest_03
  Input command : Cancel Order Request for a Filled Order
  Expected beahvior : OrderCancelled entity should not be generated


    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | PFILL       | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When CancelOrderRequest received with these input parameters
      | symbol | orderId       | comment        |
      | AAPL   | Of-0000000001 | Not Interested |

    Then no events should be generated

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | FILL        |


  Scenario: OnCancelRequest_04
  Input command : Cancel Order Request for a Rejected Order
  Expected beahvior : OrderCancelled entity should not be generated


    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | REJ         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When CancelOrderRequest received with these input parameters
      | symbol | orderId       | comment        |
      | AAPL   | Of-0000000001 | Not Interested |

    Then no events should be generated

    And Order entity state as follows
      | orderId       | symbol | orderStatus |
      | Of-0000000001 | AAPL   | REJ         |
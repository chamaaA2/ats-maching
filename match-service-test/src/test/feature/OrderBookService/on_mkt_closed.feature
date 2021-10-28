Feature: on_mkt_closed

  Test OnMktClosed Event handler

  entity:
  input command: TickerQuoteUpdated
  output event: MDQuoteUpdated MDQuoteCreated
  functionality: Create or Update MDQuote Entity

  Background:
    Given testing OnMktClosed functionality of MatchingService for root id AAPL
    And system date is 2021/10/26 and time is 12:30:00


  Scenario: OnMktClosed_01
  Input Command :expire date 2021/10/27
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_02
  Input Command : is market open false
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | false        |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_03
  Input Command : order type peg mid point
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_MIDPT | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_04
  Input Command : order type PEG_MARKET
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType  | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_MARKET | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | GTD | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_05
  Input Command : tif FOK
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType  | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_MARKET | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | FOK | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_06
  Input Command : tif IOC
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType  | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_MARKET | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | IOC | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_07
  Input Command : tif DAY
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType  | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_MARKET | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/27 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |

  Scenario: OnMktClosed_08
  Input Command : order type MARKET
  Expected Behaviour : Order Expired Entity should be generated

    Given OrderBook entity exist as follows
      | symbol | isMarketOpen |
      | AAPL   | true         |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | MARKET    | NEW         | 0             | `toEpoch('2021/10/26 09:31:00')` | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    When MktClosed received with these input parameters
      | symbol | date       | time                             |
      | AAPL   | 2021-10-26 | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderExpired |
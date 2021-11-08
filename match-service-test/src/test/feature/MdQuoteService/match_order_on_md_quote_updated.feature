Feature: match_order_on_md_quote_updated

  Test OnMatchOrderOnMdQuoteUpdated Event handler

  entity: MDQuote
  input command: MDQuoteUpdated
  output event: OrderExecuted
  functionality: OrderExecuted

  Background:
    Given testing MatchOrderOnMdQuoteUpdated functionality of MatchingService for root id AAPL


  Scenario: MatchOrderOnMdQuoteUpdatedHandler_01

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/18 09:29:00')` |

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 40         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 40         | 0          | 10    | 0           |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 12  | `toEpoch('2021/10/27 09:31:00')` |

    Then following events should be generated
      | OrderExecuted |


  Scenario: MatchOrderOnMdQuoteUpdatedHandler_02

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:29:00')` |

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT       | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |
      | order_3 | APPL   | 40       | BUY  | PEG_MARKET  | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_4 | APPL   | 40       | SELL | PEG_MIDPT   | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:32:00')` |

    Then following events should be generated
      | OrderExecuted |


  Scenario: MatchOrderOnMdQuoteUpdatedHandler_03

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/18 09:29:00')` |

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT       | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |
      | order_3 | APPL   | 40       | BUY  | PEG_MARKET  | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_4 | APPL   | 40       | SELL | PEG_MIDPT   | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/18 09:33:00')` |

    Then following events should be generated
      | OrderRepriced |

    And Order entity state as follows
      | orderId | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT       | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | PEG_PRIMARY | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |
      | order_3 | APPL   | 40       | BUY  | PEG_MARKET  | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_4 | APPL   | 40       | SELL | PEG_MIDPT   | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10.5  | 0           |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 40      | 11        |
      | order_2 | FIL         | 40      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |
      | order_1 | FIL         | 40            |
      | order_2 | FIL         | 40            |


  Scenario: MatchOrderOnMdQuoteUpdatedHandler_04

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/18 09:29:00')` |

    Given Order entity exist as follows
      | orderId | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime                        | userId   | tif | displayQty | minimumQty | price | expireDates |
      | order_1 | APPL   | 40       | BUY  | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:30:00')` | userId_1 | DAY | 25         | 0          | 11    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |
      | order_2 | APPL   | 40       | SELL | LIMIT     | NEW         | 0             | `toEpoch('2021/10/18 09:31:00')` | userId_2 | DAY | 10         | 0          | 10    | 0           |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 12  | `toEpoch('2021/10/18 09:32:00')` |

    Then following events should be generated
      | OrderExecuted |

    And OrderExecuted event expected result like this
      | orderId | orderStatus | lastQty | lastPrice |
      | order_1 | FIL         | 40      | 11        |
      | order_2 | FIL         | 40      | 11        |

    And Order entity state as follows
      | orderId | orderStatus | cumulativeQty |
      | order_1 | FIL         | 40            |
      | order_2 | FIL         | 40            |

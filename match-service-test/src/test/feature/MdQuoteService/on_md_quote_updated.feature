Feature: on_md_quote_updated

  Test OnMDQuoteUpdated Event handler

  entity: MDQuote
  input command: MDQuoteUpdated
  output event: OrderRepriced
  functionality: OrderRepriced

  Background:
    Given testing OnMDQuoteUpdated functionality of MatchingService for root id AAPL
    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType   | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000001 | AAPL   | 10       | BUY  | PEG_PRIMARY | NEW         | 0             | 10        | userId_01 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |
      | Of-0000000002 | AAPL   | 15       | BUY  | MARKET      | NEW         | 0             | 15        | userId_02 | DAY | 10         | 0          | 0     | `toEpoch('2021/10/26 09:30:00')` |

    And system date is 2021/10/26 and time is 12:30:00

  Scenario: OnMDQuoteUpdate_01
    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:31:00')` |

    Then following events should be generated
      | OrderRepriced |

  Scenario: OnMDQuoteUpdate_02

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    Then following events should be generated
      | OrderRepriced |

  Scenario: OnMDQuoteUpdate_03

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000002 | AAPL   | 15       | BUY  | MARKET    | NEW         | 0             | 15        | userId_02 | DAY | 10         | 0          | 10    | `toEpoch('2021/10/26 09:30:00')` |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 12  | 15  | `toEpoch('2021/10/26 09:31:00')` |

    Then following events should be generated
      | OrderRepriced |

    And OrderRepriced event expected result like this
      | symbol |
      | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | price |
      | Of-0000000002 | AAPL   | 15    |

  Scenario: MatchOrderOnMdQuoteUpdatedHandler_04

    Given MDQuote entity exist as follows
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 10  | 11  | `toEpoch('2021/10/26 09:30:00')` |

    And Order entity exist as follows
      | orderId       | symbol | orderQty | side | orderType | orderStatus | cumulativeQty | orderTime | userId    | tif | displayQty | minimumQty | price | expireDate                       |
      | Of-0000000002 | AAPL   | 15       | BUY  | MARKET    | NEW         | 0             | 15        | userId_02 | DAY | 10         | 0          | 10    | `toEpoch('2021/10/26 09:30:00')` |

    When MDQuoteUpdated received with these input parameters
      | symbol | nbb | nbo | nbboTime                         |
      | AAPL   | 12  | 15  | `toEpoch('2021/10/26 09:31:00')` |

    Then following events should be generated
      | OrderRepriced |

    And OrderRepriced event expected result like this
      | symbol |
      | AAPL   |

    And Order entity state as follows
      | orderId       | symbol | price |
      | Of-0000000002 | AAPL   | 15    |
Feature: on_place_order_request_handler

    Test OnOrderAccepted event handler

    entities : order
    input event : OrderAccepted
    output events : OrderAccepted, OrderCancelled
    functionality : Accepts manual batch requests

    Background:
        Given testing OnOrderAccepted functionality of StockLoanDeskService for root id desk_01

        And system date is 2020/11/01 and time is 11:00:00

        And StockLoanDesk entity exist as follows
            | deskId  |
            | desk_01 |

    Scenario: SLDAcceptOnManualBatchLoanRequest_01

    Request with a single sub request received
    Expected Behaviour: SLDLoanRequestAccepted event generated

        And SLDLoanRequestEntry entity exist as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |

        And SLDManualBatchLoanRequest received with these input parameters
            | deskId  | batchRequestId | requestedTimestamp               | borrowerAccountId | batchRequestMap.AAPL.instId | batchRequestMap.AAPL.symbol | batchRequestMap.AAPL.requestQty |
            | desk_01 | BATCH_0002     | `toEpoch('2020/11/01 10:00:01')` | FIRM              | 001                         | AAPL                        | 400                             |

        Then following events should be generated
            | SLDLoanRequestAccepted |

        And SLDLoanRequestAccepted event with key internalRequestId expected result like this
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0002_001    | BATCH_0002     | 001    | AAPL   | FIRM              | 400        | `toEpoch('2020/11/01 11:00:00')` |

        And SLDLoanRequestEntry entity state as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |
            | desk_01 | BATCH_0002_001    | BATCH_0002     | 001    | AAPL   | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 11:00:00')` |

    Scenario: SLDAcceptOnManualBatchLoanRequest_02

    Request with multiple sub requests received
    Expected Behaviour: SLDLoanRequestAccepted event generated

        And SLDLoanRequestEntry entity exist as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |

        And SLDManualBatchLoanRequest received with these input parameters
            | deskId  | batchRequestId | requestedTimestamp               | borrowerAccountId | batchRequestMap.AAPL.instId | batchRequestMap.AAPL.symbol | batchRequestMap.AAPL.requestQty | batchRequestMap.BAC.instId | batchRequestMap.BAC.symbol | batchRequestMap.BAC.requestQty |
            | desk_01 | BATCH_0002     | `toEpoch('2020/11/01 10:00:01')` | FIRM              | 001                         | AAPL                        | 400                             | 002                        | BAC                        | 200                            |

        Then following events should be generated
            | SLDLoanRequestAccepted |

        And SLDLoanRequestAccepted event with key internalRequestId expected result like this
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0002_001    | BATCH_0002     | 001    | AAPL   | FIRM              | 400        | `toEpoch('2020/11/01 11:00:00')` |
            | desk_01 | BATCH_0002_002    | BATCH_0002     | 002    | BAC    | FIRM              | 200        | `toEpoch('2020/11/01 11:00:00')` |

        And SLDLoanRequestEntry entity state as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |
            | desk_01 | BATCH_0002_001    | BATCH_0002     | 001    | AAPL   | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 11:00:00')` |
            | desk_01 | BATCH_0002_002    | BATCH_0002     | 002    | BAC    | FIRM              | 200        | 0                  | 0              | `toEpoch('2020/11/01 11:00:00')` |

    Scenario: SLDAcceptOnManualBatchLoanRequest_03

    Request with multiple sub requests received with one requestQty=0 for one sub request
    Expected Behaviour: no events generated and errorCode INVALID_REQUEST_QTY

        And SLDLoanRequestEntry entity exist as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |

        And SLDManualBatchLoanRequest received with these input parameters
            | deskId  | batchRequestId | requestedTimestamp               | borrowerAccountId | batchRequestMap.AAPL.instId | batchRequestMap.AAPL.symbol | batchRequestMap.AAPL.requestQty | batchRequestMap.BAC.instId | batchRequestMap.BAC.symbol | batchRequestMap.BAC.requestQty |
            | desk_01 | BATCH_0002     | `toEpoch('2020/11/01 10:00:01')` | FIRM              | 001                         | AAPL                        | 0                               | 002                        | BAC                        | 200                            |

        And error occurred with errorCode INVALID_REQUEST_QTY without parameters

    Scenario: SLDAcceptOnManualBatchLoanRequest_04

    Request with multiple sub requests received with negative requestQty for one sub request
    Expected Behaviour: no events generated and errorCode INVALID_REQUEST_QTY

        And SLDLoanRequestEntry entity exist as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |

        And SLDManualBatchLoanRequest received with these input parameters
            | deskId  | batchRequestId | requestedTimestamp               | borrowerAccountId | batchRequestMap.AAPL.instId | batchRequestMap.AAPL.symbol | batchRequestMap.AAPL.requestQty | batchRequestMap.BAC.instId | batchRequestMap.BAC.symbol | batchRequestMap.BAC.requestQty |
            | desk_01 | BATCH_0002     | `toEpoch('2020/11/01 10:00:01')` | FIRM              | 001                         | AAPL                        | -400                            | 002                        | BAC                        | 200                            |

        And error occurred with errorCode INVALID_REQUEST_QTY without parameters

    Scenario: SLDAcceptOnManualBatchLoanRequest_05

    Request with multiple sub requests received with one requestQty either 0 or negative for all sub requests
    Expected Behaviour: no events generated and errorCode INVALID_REQUEST_QTY

        And SLDLoanRequestEntry entity exist as follows
            | deskId  | internalRequestId | batchRequestId | instId | symbol | borrowerAccountId | requestQty | adjustedRequestQty | loanCreatedQty | requestReceivedTimestamp         |
            | desk_01 | BATCH_0001_002    | BATCH_0001     | 002    | BAC    | FIRM              | 400        | 0                  | 0              | `toEpoch('2020/11/01 10:00:00')` |

        And SLDManualBatchLoanRequest received with these input parameters
            | deskId  | batchRequestId | requestedTimestamp               | borrowerAccountId | batchRequestMap.AAPL.instId | batchRequestMap.AAPL.symbol | batchRequestMap.AAPL.requestQty | batchRequestMap.BAC.instId | batchRequestMap.BAC.symbol | batchRequestMap.BAC.requestQty |
            | desk_01 | BATCH_0002     | `toEpoch('2020/11/01 10:00:01')` | FIRM              | 001                         | AAPL                        | 0                               | 002                        | BAC                        | -200                           |

        And error occurred with errorCode INVALID_REQUEST_QTY without parameters
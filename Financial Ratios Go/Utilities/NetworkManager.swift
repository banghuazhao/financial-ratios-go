//
//  NetworkManager.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/19/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

enum FetchError: String, Error {
    case networkError = "Network Error! Pull to reload"
    case timeoutError = "Network Timeout! Pull to reload"
    case dateNotExist = "Wrong Fiscal Period! Try others"
    case parseJSONError = "No Data"
    case networkCancelled = "Network is Cancelled!"
}

var fetchStatementTasks = [URLSessionDataTask]()

func fetchStatement(which statement: String, completion: @escaping (Result<String, FetchError>) -> Void) {
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 60

    let fetchCompany = company
    let companySymbol = company.symbol
    let period = fiscalPeriod.period
    let finanicalDate = fiscalPeriod.time
    var success = false

    var urlString = ""
    if period == "Annually" {
        urlString = "https://financialmodelingprep.com/api/v3/\(statement)/\(companySymbol)?apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    } else {
        urlString = "https://financialmodelingprep.com/api/v3/\(statement)/\(companySymbol)?period=quarter&apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    if let url = URL(string: urlString) {
        let fetchStatementTask = URLSession(configuration: sessionConfig).dataTask(with: url) { data, _, err in
            if let err = err {
                if err._code == NSURLErrorTimedOut {
                    print("Time Out: \(err)")
                    completion(.failure(.timeoutError))
                    return
                } else if err._code == NSURLErrorCancelled {
                    print("Network Cancelled: \(err)")
                    completion(.failure(.networkCancelled))
                    return
                }
                print("Network Error: \(err)")
                completion(.failure(.networkError))
                return
            }

            guard let data = data else {
                completion(.failure(.parseJSONError))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let financialDicts = json as? [[String: Any]] else {
                    completion(.failure(.parseJSONError))
                    return
                }
//                print(financialDicts)
                for financialDict in financialDicts {
                    guard let date = financialDict["date"] as? String else {
                        completion(.failure(.parseJSONError))
                        return
                    }

                    saveStatementToLocal(company: fetchCompany, statementName: statement, statement: financialDict, fiscalPeriod: date, period: period)

                    if finanicalDate == date {
                        if statement == "income-statement" {
                            for key in incomeStatementValues.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                incomeStatementValues[key] = String(value)
                            }
                        } else if statement == "balance-sheet-statement" {
                            for key in balanceSheetStatementValues.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                balanceSheetStatementValues[key] = String(value)
                            }
                        } else if statement == "cash-flow-statement" {
                            for key in cashFlowStatementValues.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                cashFlowStatementValues[key] = String(value)
                            }
                        }
                        success = true
                    }
                }

                if success {
                    completion(.success("Succeed!"))
                    return
                } else {
                    completion(.failure(.dateNotExist))
                    return
                }

            } catch let jsonError {
                print("Parse JSON error: \(jsonError)")
                completion(.failure(.parseJSONError))
                return
            }
        }

        fetchStatementTask.resume()

        fetchStatementTasks.append(fetchStatementTask)
    }
}

var fetchStatementCompareTasks = [URLSessionDataTask]()

func fetchStatementCompare(which statement: String, completion: @escaping (Result<String, FetchError>) -> Void) {
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 60

    let localCompareCompany = compareCompany
    let companySymbol = compareCompany.symbol
    let period1 = fiscalPeriod1.period
    let finanicalDate1 = fiscalPeriod1.time
//    let period2 = fiscalPeriod2.period
    let finanicalDate2 = fiscalPeriod2.time
    var flag = 0

    var urlString = ""
    if period1 == "Annually" {
        urlString = "https://financialmodelingprep.com/api/v3/\(statement)/\(companySymbol)?apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    } else {
        urlString = "https://financialmodelingprep.com/api/v3/\(statement)/\(companySymbol)?period=quarter&apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
    }

    if let url = URL(string: urlString) {
        let fetchStatementCompareTask = URLSession(configuration: sessionConfig).dataTask(with: url) { data, _, err in
            if let err = err {
                if err._code == NSURLErrorTimedOut {
                    print("Time Out: \(err)")
                    completion(.failure(.timeoutError))
                    return
                } else if err._code == NSURLErrorCancelled {
                    print("Network Cancelled: \(err)")
                    completion(.failure(.networkCancelled))
                    return
                }
                print("Network Error: \(err)")
                completion(.failure(.networkError))
                return
            }

            guard let data = data else {
                completion(.failure(.parseJSONError))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let financialDicts = json as? [[String: Any]] else {
                    completion(.failure(.parseJSONError))
                    return
                }
//                print(financialDicts)
                for financialDict in financialDicts {
                    guard let date = financialDict["date"] as? String else {
                        completion(.failure(.parseJSONError))
                        return
                    }

                    saveCompareStatementToLocal(company: localCompareCompany, statementName: statement, statement: financialDict, fiscalPeriod: date, period: period1)

                    if finanicalDate1 == date {
                        if statement == "income-statement" {
                            for key in incomeStatementValues1.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                incomeStatementValues1[key] = String(value)
                            }
                        } else if statement == "balance-sheet-statement" {
                            for key in balanceSheetStatementValues1.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                balanceSheetStatementValues1[key] = String(value)
                            }
                        } else if statement == "cash-flow-statement" {
                            for key in cashFlowStatementValues1.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                cashFlowStatementValues1[key] = String(value)
                            }
                        }
                        flag += 1
                    }

                    if finanicalDate2 == date {
                        if statement == "income-statement" {
                            for key in incomeStatementValues2.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                incomeStatementValues2[key] = String(value)
                            }
                        } else if statement == "balance-sheet-statement" {
                            for key in balanceSheetStatementValues2.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                balanceSheetStatementValues2[key] = String(value)
                            }
                        } else if statement == "cash-flow-statement" {
                            for key in cashFlowStatementValues2.keys {
                                guard let value = financialDict[key] as? Double else {
                                    continue
                                }
                                cashFlowStatementValues2[key] = String(value)
                            }
                        }
                        flag += 1
                    }
                }

                if flag == 2 {
                    completion(.success("Succeed!"))
                    return
                } else {
                    completion(.failure(.dateNotExist))
                    return
                }

            } catch let jsonError {
                print("Parse JSON error: \(jsonError)")
                completion(.failure(.parseJSONError))
                return
            }
        }

        fetchStatementCompareTask.resume()

        fetchStatementCompareTasks.append(fetchStatementCompareTask)
    }
}

func cancelfetchStatementTask() {
    fetchStatementTasks.forEach { $0.cancel() }
    fetchStatementTasks = []
}

func cancelfetchStatementCompareTask() {
    fetchStatementCompareTasks.forEach { $0.cancel() }
    fetchStatementCompareTasks = []
}

var fetchFiscalPeriodTasks = [URLSessionDataTask]()
var fetchAndCacheFiscalPeriodTasks = [URLSessionDataTask]()

func fetchFinanicalPeriod(newCompany: Company, period: String, completion: @escaping (Result<String, FetchError>) -> Void) {
    let sessionConfig = URLSessionConfiguration.default
    sessionConfig.timeoutIntervalForRequest = 60

    var urlString = ""
    if period == "Annually" {
        guard let urlString1 = "https://financialmodelingprep.com/api/v3/income-statement/\(newCompany.symbol)?limit=10&apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        urlString = urlString1
    } else {
        guard let urlString2 = "https://financialmodelingprep.com/api/v3/income-statement/\(newCompany.symbol)?period=quarter&limit=40&apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        urlString = urlString2
    }

    if let url = URL(string: urlString) {
        let fetchFiscalPeriodTask = URLSession(configuration: sessionConfig).dataTask(with: url) { data, _, err in
            if let err = err {
                if err._code == NSURLErrorTimedOut {
                    print("Time Out: \(err)")
                    completion(.failure(.timeoutError))
                    return
                } else if err._code == NSURLErrorCancelled {
                    print("Network Cancelled: \(err)")
                    completion(.failure(.networkCancelled))
                    return
                }
                print("Network Error: \(err)")
                completion(.failure(.networkError))
                return
            }

            guard let data = data else {
                completion(.failure(.parseJSONError))
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                guard let financialDicts = json as? [[String: Any]] else {
                    completion(.failure(.parseJSONError))
                    return
                }
                var financialPeriods = [FiscalPeriod]()
                for financialDict in financialDicts {
                    guard let date = financialDict["date"] as? String else {
                        completion(.failure(.parseJSONError))
                        return
                    }

                    let path = getStatmentCachePath().appendingPathComponent("\(newCompany.name)_\(newCompany.symbol)_\(date)_\(period)_income-statement")

                    if !fileManager.fileExists(atPath: path.path) {
                        saveStatementToLocal(company: newCompany, statementName: "income-statement", statement: financialDict, fiscalPeriod: date, period: period)
                    }

                    if period == "Annually" {
                        financialPeriods.append(FiscalPeriod(time: date, period: "Annually"))
                    } else {
                        financialPeriods.append(FiscalPeriod(time: date, period: "Quarterly"))
                    }
                }

                if period == "Annually" {
                    financialTimesAnnually = financialPeriods
                } else {
                    financialTimesQuarterly = financialPeriods
                }

                // cache result
                saveFiscalPeriodToLocal(newCompany: newCompany, period: period, fiscalPeriod: financialPeriods)

                completion(.success("succeed"))
                return
            } catch let jsonError {
                print("Parse JSON error: \(jsonError)")
                completion(.failure(.parseJSONError))
                return
            }
        }
        fetchFiscalPeriodTask.resume()
        fetchFiscalPeriodTasks.append(fetchFiscalPeriodTask)
    }
}

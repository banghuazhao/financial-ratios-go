//
//  FileManager.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

let fileManager = FileManager.default

func getCacheDirectory() -> URL {
    let paths = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)
    let cachesDirectory = paths[0]
    return cachesDirectory
}

func getCacheDirectorySize() -> String {
    let cachePathURL = fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    // check if the url is a directory
    if (try? cachePathURL.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory == true {
        var folderSize = 0
        folderSize += sizeOfFolder(getStatmentCachePath().path)
        folderSize += sizeOfFolder(getFiscalPeriodCachePath().path)
        folderSize += sizeOfFolder(getCompanyLogoCachePath().path)
        let byteCountFormatter = ByteCountFormatter()
        switch folderSize {
        case 0 ..< 1024:
            byteCountFormatter.allowedUnits = .useBytes
        case 1024 ..< 1024 * 1024:
            byteCountFormatter.allowedUnits = .useKB
        case 1024 * 1024 ..< 1024 * 1024 * 1024:
            byteCountFormatter.allowedUnits = .useMB
        default:
            byteCountFormatter.allowedUnits = .useGB
        }

        byteCountFormatter.countStyle = .file
        let sizeToDisplay = byteCountFormatter.string(for: folderSize) ?? ""
        return sizeToDisplay
    }
    return "0"
}

func sizeOfFolder(_ folderPath: String) -> Int {
    do {
        let contents = try fileManager.contentsOfDirectory(atPath: folderPath)
        var folderSize: Int = 0
        for content in contents {
            do {
                let fullContentPath = folderPath + "/" + content
                let fileAttributes = try FileManager.default.attributesOfItem(atPath: fullContentPath)
                folderSize += fileAttributes[FileAttributeKey.size] as? Int ?? 0
            } catch _ {
                continue
            }
        }
        return folderSize
    } catch let error {
        print(error.localizedDescription)
        return 0
    }
}

func clearCacheOfLocal() {
    do {
        try FileManager.default.removeItem(at: getStatmentCachePath())
        try FileManager.default.removeItem(at: getFiscalPeriodCachePath())
        try FileManager.default.removeItem(at: getCompanyLogoCachePath())
    } catch let error {
        print(error)
    }
}

// MARK: - statement related

func getStatmentCachePath() -> URL {
    let cachePath = getCacheDirectory().appendingPathComponent("Statement")

    if !fileManager.fileExists(atPath: cachePath.path) {
        do {
            try fileManager.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
    }
    return cachePath
}

func saveStatementToLocal(company: Company, statementName: String, statement: Dictionary<String, Any>, fiscalPeriod: String, period: String) {
    let path = getStatmentCachePath().appendingPathComponent("\(company.name)_\(company.symbol)_\(fiscalPeriod)_\(period)_\(statementName)")
//    print(path)

    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: statement, requiringSecureCoding: true)
        fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
    } catch let error {
        print(error)
    }
}

func saveCompareStatementToLocal(company: Company, statementName: String, statement: Dictionary<String, Any>, fiscalPeriod: String, period: String) {
    let path = getStatmentCachePath().appendingPathComponent("\(company.name)_\(company.symbol)_\(fiscalPeriod)_\(period)_\(statementName)")
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: statement, requiringSecureCoding: true) as Data
        fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
    } catch let error {
        print(error)
    }
}

func readStatmentFromLocal(company: Company, fiscalPeriod: FiscalPeriod, statementName: String) -> Bool {
    let path = getStatmentCachePath().appendingPathComponent("\(company.name)_\(company.symbol)_\(fiscalPeriod.time)_\(fiscalPeriod.period)_\(statementName)")

    if !fileManager.fileExists(atPath: path.path) {
        return false
    } else {
        let dataFromPath = fileManager.contents(atPath: path.path)
        guard let data = dataFromPath else { return false }
        do {
            let localStatment = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? Dictionary<String, Any>
            switch statementName {
            case "income-statement":
                for key in incomeStatementValues.keys {
                    incomeStatementValues[key] = String(localStatment?[key] as? Double ?? 0)
                }
                return true
            case "balance-sheet-statement":
                for key in balanceSheetStatementValues.keys {
                    balanceSheetStatementValues[key] = String(localStatment?[key] as? Double ?? 0)
                }
                return true
            case "cash-flow-statement":
                for key in cashFlowStatementValues.keys {
                    cashFlowStatementValues[key] = String(localStatment?[key] as? Double ?? 0)
                }
                return true
            default:
                return false
            }
        } catch let error {
            print(error)
            return false
        }
    }
}

func readStatmentFromLocalCompare(company: Company, fiscalPeriod1: FiscalPeriod, fiscalPeriod2: FiscalPeriod, statementName: String) -> Bool {
    let path1 = getStatmentCachePath().appendingPathComponent("\(company.name)_\(company.symbol)_\(fiscalPeriod1.time)_\(fiscalPeriod1.period)_\(statementName)")

    let path2 = getStatmentCachePath().appendingPathComponent("\(company.name)_\(company.symbol)_\(fiscalPeriod2.time)_\(fiscalPeriod2.period)_\(statementName)")

    if !fileManager.fileExists(atPath: path1.path) || !fileManager.fileExists(atPath: path2.path) {
        return false
    } else {
        let dataFromPath1 = fileManager.contents(atPath: path1.path)
        let dataFromPath2 = fileManager.contents(atPath: path2.path)

        guard let data1 = dataFromPath1 else { return false }
        guard let data2 = dataFromPath2 else { return false }

        do {
            let localStatment1 = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data1) as? Dictionary<String, Any>
            let localStatment2 = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data2) as? Dictionary<String, Any>
            switch statementName {
            case "income-statement":
                for key in incomeStatementValues1.keys {
                    incomeStatementValues1[key] = String(localStatment1?[key] as? Double ?? 0)
                }
                for key in incomeStatementValues2.keys {
                    incomeStatementValues2[key] = String(localStatment2?[key] as? Double ?? 0)
                }
                return true
            case "balance-sheet-statement":
                for key in balanceSheetStatementValues1.keys {
                    balanceSheetStatementValues1[key] = String(localStatment1?[key] as? Double ?? 0)
                }
                for key in balanceSheetStatementValues2.keys {
                    balanceSheetStatementValues2[key] = String(localStatment2?[key] as? Double ?? 0)
                }
                return true
            case "cash-flow-statement":
                for key in cashFlowStatementValues1.keys {
                    cashFlowStatementValues1[key] = String(localStatment1?[key] as? Double ?? 0)
                }
                for key in cashFlowStatementValues2.keys {
                    cashFlowStatementValues2[key] = String(localStatment2?[key] as? Double ?? 0)
                }
                return true
            default:
                return false
            }
        } catch let error {
            print(error)
            return false
        }
    }
}

// MARK: fiscal period related

func getFiscalPeriodCachePath() -> URL {
    let cachePath = getCacheDirectory().appendingPathComponent("FiscalPeriod")

    if !fileManager.fileExists(atPath: cachePath.path) {
        do {
            try fileManager.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
    }
    return cachePath
}

func saveFiscalPeriodToLocal(newCompany: Company, period: String, fiscalPeriod: [FiscalPeriod]) {
    let path = getFiscalPeriodCachePath().appendingPathComponent("\(newCompany.name)_\(newCompany.symbol)_\(period)")
//    print("did saveFiscalPeriodToLocal at: \(path.path)")
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: fiscalPeriod, requiringSecureCoding: true)
        fileManager.createFile(atPath: path.path, contents: data, attributes: nil)
    } catch let error {
        print(error)
    }
}

func readFiscalPeriodFromLocal(newCompany: Company, period: String) -> Bool {
    let path = getFiscalPeriodCachePath().appendingPathComponent("\(newCompany.name)_\(newCompany.symbol)_\(period)")
//    print(path.path)
    if !fileManager.fileExists(atPath: path.path) {
        return false
    } else {
        let dataFromPath = fileManager.contents(atPath: path.path)

        guard let data = dataFromPath else { return false }

        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 180

        var urlString = ""
        if period == "Annually" {
            guard let urlString1 = "https://financialmodelingprep.com/api/v3/income-statement/\(newCompany.symbol)?apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return false }
            urlString = urlString1
        } else {
            guard let urlString2 = "https://financialmodelingprep.com/api/v3/income-statement/\(newCompany.symbol)?period=quarter&?apikey=\(Constants.APIKey)".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return false }
            urlString = urlString2
        }

        if let url = URL(string: urlString) {
            let fetchFiscalPeriodTask = URLSession(configuration: sessionConfig).dataTask(with: url) { data, _, err in
                if err != nil {
                    return
                }

                guard let data = data else {
                    return
                }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let financialDicts = json as? [[String: Any]] else {
                        return
                    }
                    var financialPeriods = [FiscalPeriod]()
                    for financialDict in financialDicts {
                        guard let date = financialDict["date"] as? String else {
                            return
                        }

                        if period == "Annually" {
                            financialPeriods.append(FiscalPeriod(time: date, period: "Annually"))
                        } else {
                            financialPeriods.append(FiscalPeriod(time: date, period: "Quarterly"))
                        }
                    }

                    // cache result
                    saveFiscalPeriodToLocal(newCompany: newCompany, period: period, fiscalPeriod: financialPeriods)

                    return
                } catch let jsonError {
                    print("Parse JSON error: \(jsonError)")
                    return
                }
            }
            fetchFiscalPeriodTask.resume()
        }

        do {
            let localFiscalPeriods = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(data) as? [FiscalPeriod]
            switch period {
            case "Annually":
                financialTimesAnnually = localFiscalPeriods
                return true
            case "Quarterly":
                financialTimesQuarterly = localFiscalPeriods
                return true
            default:
                return false
            }
        } catch let error {
            print(error)
            return false
        }
    }
}

// MARK: company logo related

func getCompanyLogoCachePath() -> URL {
    let cachePath = getCacheDirectory().appendingPathComponent("com.onevcat.Kingfisher.ImageCache.default")

    if !fileManager.fileExists(atPath: cachePath.path) {
        do {
            try fileManager.createDirectory(at: cachePath, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            print(error)
        }
    }
    return cachePath
}

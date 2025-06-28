//
//  CompareController.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/9/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SnapKit
import UIKit

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

class CompareController: FRGViewController {
    var headerViews: [FRGHeaderView] = {
        var headerViews: [FRGHeaderView] = []
        for (section, homeSectionHeader) in homeSectionHeaders.enumerated() {
            let headerView = FRGHeaderView()
            headerView.sectionTitle = homeSectionHeader.title.localized
            headerView.isStatic = homeSectionHeader.isStatic
            headerView.section = section
            headerViews.append(headerView)
        }
        return headerViews
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        if #available(iOS 15.0, *) {
            #if !targetEnvironment(macCatalyst)
                tableView.sectionHeaderTopPadding = 0
            #endif
        }

        tableView.register(CompanySelectedCompareCell.self, forCellReuseIdentifier: "CompanySelectedCell")
        tableView.register(FinancialStatementTitleCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(FinancialStatementCompareCell.self, forCellReuseIdentifier: "DataCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .backgroundColor

        return tableView
    }()

    lazy var calculationButton: UIButton = FRGCalculationButton()

    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()

        isSingle = false

        setupViews()

        setupCalculateButton()

        fetchFinancialDatas()

        #if !targetEnvironment(macCatalyst)
            NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isSingle = false
        setupCalculateButton()
        if isCompareFetchOnlineData {
            setupRefresh()
        }

        for (section, headerView) in headerViews.enumerated() {
            headerView.sectionTitle = homeSectionHeaders[section].title.localized
            headerView.loadingLabel.text = "Downloading...".localized
            headerView.correctLabel.text = "Download Successfully!".localized
            if let wrongType = headerView.wrongType {
                headerView.wrongLabel.text = wrongType.rawValue.localized
            }
        }
        tableView.reloadData()
        setupNav()
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }

    // MARK: - setupNav

    private func setupNav() {
        tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)

        tabBarController?.navigationItem.title = "Financial Statements".localized

        tabBarController?.navigationItem.rightBarButtonItem = nil

        let button = UIButton(type: .custom)
        button.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage(named: "bars-solid"), for: .normal)
        button.addTarget(self, action: #selector(presentMenuController), for: .touchUpInside)

        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)

        let shareButton = UIButton(type: .custom)
        shareButton.snp.makeConstraints { make in
            make.height.width.equalTo(21)
        }
        shareButton.setImage(UIImage(named: "share-square-solid"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareCompareStatement(_:)), for: .touchUpInside)

        tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)
    }

    // MARK: - setupViews

    private func setupViews() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        #if !targetEnvironment(macCatalyst)
            if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
            } else {
                view.addSubview(bannerView)
                bannerView.snp.makeConstraints { make in
                    make.height.equalTo(50)
                    make.width.equalToSuperview()
                    make.bottom.equalToSuperview()
                    make.centerX.equalToSuperview()
                }
            }
        #endif
    }

    // MARK: - setupCalculateButton

    private func setupCalculateButton() {
        calculationButton.setTitle("Calculate".localized, for: .normal)
        tabBarController?.tabBar.addSubview(calculationButton)
        calculationButton.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.centerX.equalToSuperview()
        }

        calculationButton.addTarget(self, action: #selector(calculateFunction), for: .touchUpInside)
    }

    // MARK: - fetchFinancialDatas

    func fetchFinancialDatas() {
        FinancialStatement.initializeFinancialStatementCompare()
        tableView.reloadData()
        beginfetchFinancialDatas()
    }

    fileprivate func beginfetchFinancialDatas() {
        showLoading(headerViews: headerViews)

        let fetchPlaces = ["income-statement", "balance-sheet-statement", "cash-flow-statement"]

        for i in 0 ... fetchPlaces.count - 1 {
            if !readStatmentFromLocalCompare(company: compareCompany, fiscalPeriod1: fiscalPeriod1, fiscalPeriod2: fiscalPeriod2, statementName: fetchPlaces[i]) {
                fetchStatementCompare(which: fetchPlaces[i]) { result in
                    DispatchQueue.main.async {
                        let headerView = self.headerViews[i + 1]
                        switch result {
                        case .success:
                            self.tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
                            showSuccess(headerViews: [headerView])
                        case let .failure(fetchError):
                            if fetchError.rawValue != "Network is Cancelled!" {
                                showError(headerViews: [headerView], errorDiscription: fetchError.rawValue.localized)
                                headerView.wrongType = fetchError
                            }
                        }
                    }
                }
            } else {
                let headerView = headerViews[i + 1]
                showSuccess(headerViews: [headerView])
                tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
            }
        }
    }

    func readAllLocalFinancialData() -> Bool {
        var readTime: Int = 0
        let fetchPlaces = ["income-statement", "balance-sheet-statement", "cash-flow-statement"]
        for i in 0 ... fetchPlaces.count - 1 {
            if readStatmentFromLocalCompare(company: compareCompany, fiscalPeriod1: fiscalPeriod1, fiscalPeriod2: fiscalPeriod2, statementName: fetchPlaces[i]) {
                let headerView = headerViews[i + 1]
                showSuccess(headerViews: [headerView])
                tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
                readTime += 1
            }
        }
        if readTime == 3 {
            return true
        } else {
            return false
        }
    }

    func reloadCompany() {
        tableView.reloadData()
        tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .left)
    }

    // MARK: - setupRefresh

    func setupRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.tintColor = .white
        tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }

    @objc func refresh() {
        cancelfetchStatementCompareTask()
        if !readAllLocalFinancialData() {
            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Redownloading data...".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            beginfetchFinancialDatas()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.tableView.refreshControl?.endRefreshing()
            })
        } else {
            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Refresh finished".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            tableView.refreshControl?.endRefreshing()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
}

// MARK: - actions

extension CompareController {
    #if !targetEnvironment(macCatalyst)
        @objc func handlePurchaseNotification(_ notification: Notification) {
            bannerView.removeFromSuperview()
        }
    #endif

    @objc func shareCompareStatement(_ sender: UIButton) {
        print("shareCompareStatement")
        var str: String = ""

        str += "\("Company".localized):\t\(compareCompany.name) (\(compareCompany.symbol))\n"

        str += "\("Fiscal Period".localized) 1:\t\(fiscalPeriod1.time) (\(fiscalPeriod1.period.localized))\n"
        str += "\("Fiscal Period".localized) 2:\t\(fiscalPeriod2.time) (\(fiscalPeriod2.period.localized))\n"

        str += "\n"

        str += "\("Income Statement".localized)\t\(fiscalPeriod1.time)\tvs\t\(fiscalPeriod2.time)\n"

        for i in 0 ... incomeStatementLabels.count - 1 {
            let statementValue1 = incomeStatementValues1[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!
            let statementValue2 = incomeStatementValues2[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!

            str += "\(incomeStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\n"
        }

        str += "\n"

        str += "\("Balance Sheet Statement".localized)\t\(fiscalPeriod1.time)\t\(fiscalPeriod2.time)\n"

        for i in 0 ... balanceSheetStatementLabels.count - 1 {
            let statementValue1 = balanceSheetStatementValues1[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!
            let statementValue2 = balanceSheetStatementValues2[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!

            str += "\(balanceSheetStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\n"
        }

        str += "\n"

        str += "\("Cash Flow Statement".localized)\t\(fiscalPeriod1.time)\t\(fiscalPeriod2.time)\n"

        for i in 0 ... cashFlowStatementLabels.count - 1 {
            let statementValue1 = cashFlowStatementValues1[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!
            let statementValue2 = cashFlowStatementValues2[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!

            str += "\(cashFlowStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\n"
        }

        str += "\n"

        let file = getDocumentsDirectory().appendingPathComponent("\("Financial Statements Compare".localized) \(company.symbol) \(fiscalPeriod1.time) vs \(fiscalPeriod2.time).txt")

        do {
            try str.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch let err {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("Error when create financial_ratios.txt: \(err)")
        }

        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)

        if let popoverController = activityVC.popoverPresentationController {
            popoverController.sourceRect = sender.bounds
            popoverController.sourceView = sender
            popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
        }

        present(activityVC, animated: true, completion: {
            #if !targetEnvironment(macCatalyst)
                if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                    print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
                } else {
                    if InterstitialAdsRequestHelper.increaseRequestAndCheckLoadInterstitialAd() {
                        GADInterstitialAd.load(withAdUnitID: Constants.interstitialAdID, request: GADRequest()) { ad, error in
                            if let error = error {
                                print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                                return
                            }
                            if let ad = ad {
                                ad.present(fromRootViewController: UIApplication.getTopMostViewController() ?? self)
                                InterstitialAdsRequestHelper.resetRequestCount()
                            } else {
                                print("interstitial Ad wasn't ready")
                            }
                        }
                    }
                }
            #endif
        })
    }

    // MARK: - addCompanyAndTime

    @objc func addCompanyAndTime() {
        let alertController = UIAlertController(title: "Create Financial Statement".localized, message: "New financial statement or current financial statement?".localized, preferredStyle: .alert)

        let createCompanyController = CreateNewController()

        alertController.addAction(UIAlertAction(title: "New".localized, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            let navController = FRGNavigationController(rootViewController: createCompanyController)
            createCompanyController.delegate = self
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Current".localized, style: .default, handler: { [weak self] _ in
            guard let self = self else { return }
            createCompanyController.loadCurrentStatement = true
            createCompanyController.incomeStatementValuesNew = incomeStatementValues
            createCompanyController.balanceSheetStatementValuesNew = balanceSheetStatementValues
            createCompanyController.cashFlowStatementValuesNew = cashFlowStatementValues
            let navController = FRGNavigationController(rootViewController: createCompanyController)
            createCompanyController.delegate = self
            navController.modalPresentationStyle = .fullScreen
            self.present(navController, animated: true, completion: nil)
        }))

        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)
    }

    // MARK: - presentMenuController

    @objc func presentMenuController() {
        let menuController = MenuController()
        menuController.delegate = self
        let menuNavController = FRGNavigationController(rootViewController: menuController)
        menuNavController.modalPresentationStyle = .custom
        menuNavController.transitioningDelegate = self
        present(menuNavController, animated: true, completion: nil)
    }

    // MARK: - calculateFunction

    @objc func calculateFunction(_ sender: UIButton) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        FinancialStatement.initializeFinancialStatementCompareResult()

        // 1

        // Income statement

        let revenue1 = convertCurrencyToDouble(input: incomeStatementValues1["revenue"] ?? "")
        let operatingIncome1 = convertCurrencyToDouble(input: incomeStatementValues1["operatingIncome"] ?? "")
        let EBIT1 = convertCurrencyToDouble(input: incomeStatementValues1["ebitda"] ?? "")
        let interestExpense1 = convertCurrencyToDouble(input: incomeStatementValues1["interestExpense"] ?? "")
        let incomeTaxExpense1 = convertCurrencyToDouble(input: incomeStatementValues1["incomeTaxExpense"] ?? "")
        let netIncome1 = convertCurrencyToDouble(input: incomeStatementValues1["netIncome"] ?? "")

        // balance sheet statement

        let cashAndCashEquivalents1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["cashAndCashEquivalents"] ?? "")
        let shortTermInvestments1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["shortTermInvestments"] ?? "")
        let receivables1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["netReceivables"] ?? "")
        let totalCurrentAssets1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["totalCurrentAssets"] ?? "")
        let totalAssets1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["totalAssets"] ?? "")
        let shortTermDebt1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["shortTermDebt"] ?? "")
        let longTermDebt1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["longTermDebt"] ?? "")
        let totalCurrentLiabilities1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["totalCurrentLiabilities"] ?? "")
        let totalLiabilities1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["totalLiabilities"] ?? "")
        let totalShareholdersEquity1 = convertCurrencyToDouble(input: balanceSheetStatementValues1["totalStockholdersEquity"] ?? "")

        // cash flow statement

        let operatingCashFlow1 = convertCurrencyToDouble(input: cashFlowStatementValues1["operatingCashFlow"] ?? "")
        let dividendPayments1 = convertCurrencyToDouble(input: cashFlowStatementValues1["dividendsPaid"] ?? "")
        let freeCashFlow1 = convertCurrencyToDouble(input: cashFlowStatementValues1["freeCashFlow"] ?? "")

        // 2

        // Income statement

        let revenue2 = convertCurrencyToDouble(input: incomeStatementValues2["revenue"] ?? "")
        let operatingIncome2 = convertCurrencyToDouble(input: incomeStatementValues2["operatingIncome"] ?? "")
        let EBIT2 = convertCurrencyToDouble(input: incomeStatementValues2["ebitda"] ?? "")
        let interestExpense2 = convertCurrencyToDouble(input: incomeStatementValues2["interestExpense"] ?? "")
        let incomeTaxExpense2 = convertCurrencyToDouble(input: incomeStatementValues2["incomeTaxExpense"] ?? "")
        let netIncome2 = convertCurrencyToDouble(input: incomeStatementValues2["netIncome"] ?? "")

        // balance sheet statement

        let cashAndCashEquivalents2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["cashAndCashEquivalents"] ?? "")
        let shortTermInvestments2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["shortTermInvestments"] ?? "")
        let receivables2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["netReceivables"] ?? "")
        let totalCurrentAssets2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["totalCurrentAssets"] ?? "")
        let totalAssets2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["totalAssets"] ?? "")
        let shortTermDebt2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["shortTermDebt"] ?? "")
        let longTermDebt2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["longTermDebt"] ?? "")
        let totalCurrentLiabilities2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["totalCurrentLiabilities"] ?? "")
        let totalLiabilities2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["totalLiabilities"] ?? "")
        let totalShareholdersEquity2 = convertCurrencyToDouble(input: balanceSheetStatementValues2["totalStockholdersEquity"] ?? "")

        // cash flow statement

        let operatingCashFlow2 = convertCurrencyToDouble(input: cashFlowStatementValues2["operatingCashFlow"] ?? "")
        let dividendPayments2 = convertCurrencyToDouble(input: cashFlowStatementValues2["dividendsPaid"] ?? "")
        let freeCashFlow2 = convertCurrencyToDouble(input: cashFlowStatementValues2["freeCashFlow"] ?? "")

        // calculate

        // Income statement
        if let revenue1 = revenue1, let revenue2 = revenue2 {
            incomeStatementValuesCompare1["revenue"] = String(revenue1 - revenue2)
            if revenue2 != 0 {
                incomeStatementValuesCompare2["revenue"] = String((revenue1 - revenue2) / revenue2)
            } else {
                incomeStatementValuesCompare2["revenue"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["revenue"] = "Wrong input values".localized
            incomeStatementValuesCompare2["revenue"] = "Wrong input values".localized
        }

        if let operatingIncome1 = operatingIncome1, let operatingIncome2 = operatingIncome2 {
            incomeStatementValuesCompare1["operatingIncome"] = String(operatingIncome1 - operatingIncome2)
            if operatingIncome2 != 0 {
                incomeStatementValuesCompare2["operatingIncome"] = String((operatingIncome1 - operatingIncome2) / operatingIncome2)
            } else {
                incomeStatementValuesCompare2["operatingIncome"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["operatingIncome"] = "Wrong input values".localized
            incomeStatementValuesCompare2["operatingIncome"] = "Wrong input values".localized
        }

        if let EBIT1 = EBIT1, let EBIT2 = EBIT2 {
            incomeStatementValuesCompare1["ebitda"] = String(EBIT1 - EBIT2)
            if EBIT2 != 0 {
                incomeStatementValuesCompare2["ebitda"] = String((EBIT1 - EBIT2) / EBIT2)
            } else {
                incomeStatementValuesCompare2["ebitda"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["ebitda"] = "Wrong input values".localized
            incomeStatementValuesCompare2["ebitda"] = "Wrong input values".localized
        }

        if let interestExpense1 = interestExpense1, let interestExpense2 = interestExpense2 {
            incomeStatementValuesCompare1["interestExpense"] = String(interestExpense1 - interestExpense2)
            if interestExpense2 != 0 {
                incomeStatementValuesCompare2["interestExpense"] = String((interestExpense1 - interestExpense2) / interestExpense2)
            } else {
                incomeStatementValuesCompare2["interestExpense"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["interestExpense"] = "Wrong input values".localized
            incomeStatementValuesCompare2["interestExpense"] = "Wrong input values".localized
        }

        if let incomeTaxExpense1 = incomeTaxExpense1, let incomeTaxExpense2 = incomeTaxExpense2 {
            incomeStatementValuesCompare1["incomeTaxExpense"] = String(incomeTaxExpense1 - incomeTaxExpense2)
            if incomeTaxExpense2 != 0 {
                incomeStatementValuesCompare2["incomeTaxExpense"] = String((incomeTaxExpense1 - incomeTaxExpense2) / incomeTaxExpense2)
            } else {
                incomeStatementValuesCompare2["incomeTaxExpense"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["incomeTaxExpense"] = "Wrong input values".localized
            incomeStatementValuesCompare2["incomeTaxExpense"] = "Wrong input values".localized
        }

        if let netIncome1 = netIncome1, let netIncome2 = netIncome2 {
            incomeStatementValuesCompare1["netIncome"] = String(netIncome1 - netIncome2)
            if netIncome2 != 0 {
                incomeStatementValuesCompare2["netIncome"] = String((netIncome1 - netIncome2) / netIncome2)
            } else {
                incomeStatementValuesCompare2["netIncome"] = "Wrong input values".localized
            }
        } else {
            incomeStatementValuesCompare1["netIncome"] = "Wrong input values".localized
            incomeStatementValuesCompare2["netIncome"] = "Wrong input values".localized
        }

        // balance sheet statement

        if let cashAndCashEquivalents1 = cashAndCashEquivalents1, let cashAndCashEquivalents2 = cashAndCashEquivalents2 {
            balanceSheetStatementValuesCompare1["cashAndCashEquivalents"] = String(cashAndCashEquivalents1 - cashAndCashEquivalents2)
            if cashAndCashEquivalents2 != 0 {
                balanceSheetStatementValuesCompare2["cashAndCashEquivalents"] = String((cashAndCashEquivalents1 - cashAndCashEquivalents2) / cashAndCashEquivalents2)
            } else {
                balanceSheetStatementValuesCompare2["cashAndCashEquivalents"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["cashAndCashEquivalents"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["cashAndCashEquivalents"] = "Wrong input values".localized
        }

        if let shortTermInvestments1 = shortTermInvestments1, let shortTermInvestments2 = shortTermInvestments2 {
            balanceSheetStatementValuesCompare1["shortTermInvestments"] = String(shortTermInvestments1 - shortTermInvestments2)
            if shortTermInvestments2 != 0 {
                balanceSheetStatementValuesCompare2["shortTermInvestments"] = String((shortTermInvestments1 - shortTermInvestments2) / shortTermInvestments2)
            } else {
                balanceSheetStatementValuesCompare2["shortTermInvestments"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["shortTermInvestments"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["shortTermInvestments"] = "Wrong input values".localized
        }

        if let receivables1 = receivables1, let receivables2 = receivables2 {
            balanceSheetStatementValuesCompare1["netReceivables"] = String(receivables1 - receivables2)
            if receivables2 != 0 {
                balanceSheetStatementValuesCompare2["netReceivables"] = String((receivables1 - receivables2) / receivables2)
            } else {
                balanceSheetStatementValuesCompare2["netReceivables"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["netReceivables"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["netReceivables"] = "Wrong input values".localized
        }

        if let totalCurrentAssets1 = totalCurrentAssets1, let totalCurrentAssets2 = totalCurrentAssets2 {
            balanceSheetStatementValuesCompare1["totalCurrentAssets"] = String(totalCurrentAssets1 - totalCurrentAssets2)
            if totalCurrentAssets2 != 0 {
                balanceSheetStatementValuesCompare2["totalCurrentAssets"] = String((totalCurrentAssets1 - totalCurrentAssets2) / totalCurrentAssets2)
            } else {
                balanceSheetStatementValuesCompare2["totalCurrentAssets"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["totalCurrentAssets"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["totalCurrentAssets"] = "Wrong input values".localized
        }

        if let totalAssets1 = totalAssets1, let totalAssets2 = totalAssets2 {
            balanceSheetStatementValuesCompare1["totalAssets"] = String(totalAssets1 - totalAssets2)
            if totalAssets2 != 0 {
                balanceSheetStatementValuesCompare2["totalAssets"] = String((totalAssets1 - totalAssets2) / totalAssets2)
            } else {
                balanceSheetStatementValuesCompare2["totalAssets"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["totalAssets"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["totalAssets"] = "Wrong input values".localized
        }

        if let shortTermDebt1 = shortTermDebt1, let shortTermDebt2 = shortTermDebt2 {
            balanceSheetStatementValuesCompare1["shortTermDebt"] = String(shortTermDebt1 - shortTermDebt2)
            if shortTermDebt2 != 0 {
                balanceSheetStatementValuesCompare2["shortTermDebt"] = String((shortTermDebt1 - shortTermDebt2) / shortTermDebt2)
            } else {
                balanceSheetStatementValuesCompare2["shortTermDebt"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["shortTermDebt"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["shortTermDebt"] = "Wrong input values".localized
        }

        if let longTermDebt1 = longTermDebt1, let longTermDebt2 = longTermDebt2 {
            balanceSheetStatementValuesCompare1["longTermDebt"] = String(longTermDebt1 - longTermDebt2)
            if longTermDebt2 != 0 {
                balanceSheetStatementValuesCompare2["longTermDebt"] = String((longTermDebt1 - longTermDebt2) / longTermDebt2)
            } else {
                balanceSheetStatementValuesCompare2["longTermDebt"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["longTermDebt"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["longTermDebt"] = "Wrong input values".localized
        }

        if let totalCurrentLiabilities1 = totalCurrentLiabilities1, let totalCurrentLiabilities2 = totalCurrentLiabilities2 {
            balanceSheetStatementValuesCompare1["totalCurrentLiabilities"] = String(totalCurrentLiabilities1 - totalCurrentLiabilities2)
            if totalCurrentLiabilities2 != 0 {
                balanceSheetStatementValuesCompare2["totalCurrentLiabilities"] = String((totalCurrentLiabilities1 - totalCurrentLiabilities2) / totalCurrentLiabilities2)
            } else {
                balanceSheetStatementValuesCompare2["totalCurrentLiabilities"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["totalCurrentLiabilities"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["totalCurrentLiabilities"] = "Wrong input values".localized
        }

        if let totalLiabilities1 = totalLiabilities1, let totalLiabilities2 = totalLiabilities2 {
            balanceSheetStatementValuesCompare1["totalLiabilities"] = String(totalLiabilities1 - totalLiabilities2)
            if totalLiabilities2 != 0 {
                balanceSheetStatementValuesCompare2["totalLiabilities"] = String((totalLiabilities1 - totalLiabilities2) / totalLiabilities2)
            } else {
                balanceSheetStatementValuesCompare2["totalLiabilities"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["totalLiabilities"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["totalLiabilities"] = "Wrong input values".localized
        }

        if let totalShareholdersEquity1 = totalShareholdersEquity1, let totalShareholdersEquity2 = totalShareholdersEquity2 {
            balanceSheetStatementValuesCompare1["totalStockholdersEquity"] = String(totalShareholdersEquity1 - totalShareholdersEquity2)
            if totalShareholdersEquity2 != 0 {
                balanceSheetStatementValuesCompare2["totalStockholdersEquity"] = String((totalShareholdersEquity1 - totalShareholdersEquity2) / totalShareholdersEquity2)
            } else {
                balanceSheetStatementValuesCompare2["totalStockholdersEquity"] = "Wrong input values".localized
            }
        } else {
            balanceSheetStatementValuesCompare1["totalStockholdersEquity"] = "Wrong input values".localized
            balanceSheetStatementValuesCompare2["totalStockholdersEquity"] = "Wrong input values".localized
        }

        // cash flow statement

        if let operatingCashFlow1 = operatingCashFlow1, let operatingCashFlow2 = operatingCashFlow2 {
            cashFlowStatementValuesCompare1["operatingCashFlow"] = String(operatingCashFlow1 - operatingCashFlow2)
            if operatingCashFlow2 != 0 {
                cashFlowStatementValuesCompare2["operatingCashFlow"] = String((operatingCashFlow1 - operatingCashFlow2) / operatingCashFlow2)
            } else {
                cashFlowStatementValuesCompare2["operatingCashFlow"] = "Wrong input values".localized
            }
        } else {
            cashFlowStatementValuesCompare1["operatingCashFlow"] = "Wrong input values".localized
            cashFlowStatementValuesCompare2["operatingCashFlow"] = "Wrong input values".localized
        }

        if let dividendPayments1 = dividendPayments1, let dividendPayments2 = dividendPayments2 {
            cashFlowStatementValuesCompare1["dividendsPaid"] = String(dividendPayments1 - dividendPayments2)
            if dividendPayments2 != 0 {
                cashFlowStatementValuesCompare2["dividendsPaid"] = String((dividendPayments1 - dividendPayments2) / dividendPayments2)
            } else {
                cashFlowStatementValuesCompare2["dividendsPaid"] = "Wrong input values".localized
            }
        } else {
            cashFlowStatementValuesCompare1["dividendsPaid"] = "Wrong input values".localized
            cashFlowStatementValuesCompare2["dividendsPaid"] = "Wrong input values".localized
        }

        if let freeCashFlow1 = freeCashFlow1, let freeCashFlow2 = freeCashFlow2 {
            cashFlowStatementValuesCompare1["freeCashFlow"] = String(freeCashFlow1 - freeCashFlow2)
            if freeCashFlow2 != 0 {
                cashFlowStatementValuesCompare2["freeCashFlow"] = String((freeCashFlow1 - freeCashFlow2) / freeCashFlow2)
            } else {
                cashFlowStatementValuesCompare2["freeCashFlow"] = "Wrong input values".localized
            }
        } else {
            cashFlowStatementValuesCompare1["freeCashFlow"] = "Wrong input values".localized
            cashFlowStatementValuesCompare2["freeCashFlow"] = "Wrong input values".localized
        }

        let ResultVC = ResultCompareController()
        ResultVC.delegate = self

        let navController = FRGNavigationController(rootViewController: ResultVC)

        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true, completion: nil)
    }
}

// MARK: MenuControllerDelegate

extension CompareController: MenuControllerDelegate {
    func didChangeLanguage() {
        tabBarController?.navigationItem.title = "Financial Statements".localized
        setupCalculateButton()
        tabBarController?.viewControllers?[0].tabBarItem.title = "Financial Ratios".localized
        tabBarController?.viewControllers?[1].tabBarItem.title = "Statement Compare".localized
        tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
        if isCompareFetchOnlineData {
            setupRefresh()
        }

        for (section, headerView) in headerViews.enumerated() {
            headerView.sectionTitle = homeSectionHeaders[section].title.localized
            headerView.loadingLabel.text = "Downloading...".localized
            headerView.correctLabel.text = "Download Successfully!".localized
            if let wrongType = headerView.wrongType {
                headerView.wrongLabel.text = wrongType.rawValue.localized
            }
        }
        tableView.reloadData()
    }
}

// MARK: Table view delegate and data source

extension CompareController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return homeSectionHeaders.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()

        return footerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return incomeStatementLabels.count + 1
        case 2:
            return balanceSheetStatementLabels.count + 1
        case 3:
            return cashFlowStatementLabels.count + 1
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return companyRowHeight + 16
        default:
            return statementRowHeight
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let companyCell = tableView.dequeueReusableCell(withIdentifier: "CompanySelectedCell", for: indexPath) as! CompanySelectedCompareCell
            companyCell.accessoryType = .disclosureIndicator

            companyCell.companyIconView.image = UIImage(data: compareCompany.logoImage)
            companyCell.companyNameAndCodeLabel.text = "\(compareCompany.name) (\(compareCompany.symbol))"
            companyCell.financialTime1.text = "\(fiscalPeriod1.time) (\(fiscalPeriod1.period.localized))"
            companyCell.financialTime2.text = "\(fiscalPeriod2.time) (\(fiscalPeriod2.period.localized))"

            return companyCell
        case 1:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Fiscal Period".localized
                titleCell.financialPeriod1.text = "\(fiscalPeriod1.time)"
                titleCell.financialPeriod2.text = "\(fiscalPeriod2.time)"
                return titleCell
            } else {
                let incomeStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCompareCell

                incomeStatementCell.financialDataLabel.text = incomeStatementLabels[indexPath.row - 1].localized

                // 1
                incomeStatementCell.financialDataTextField1.text = convertStringToCurrency(amount: incomeStatementValues1[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row - 1]]!] ?? "")
                incomeStatementCell.financialDataTextField1.placeholder = "Enter Value".localized
                incomeStatementCell.financialDataTextField1.delegate = self
                incomeStatementCell.financialDataTextField1.tag = 1

                // 2
                incomeStatementCell.financialDataTextField2.text = convertStringToCurrency(amount: incomeStatementValues2[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row - 1]]!] ?? "")
                incomeStatementCell.financialDataTextField2.placeholder = "Enter Value".localized
                incomeStatementCell.financialDataTextField2.delegate = self
                incomeStatementCell.financialDataTextField2.tag = 2

                if isCorrectCurrency(textField: incomeStatementCell.financialDataTextField1) {
                    incomeStatementCell.financialDataTextField1.textColor = .black
                } else {
                    incomeStatementCell.financialDataTextField1.textColor = .red
                }

                if isCorrectCurrency(textField: incomeStatementCell.financialDataTextField2) {
                    incomeStatementCell.financialDataTextField2.textColor = .black
                } else {
                    incomeStatementCell.financialDataTextField2.textColor = .red
                }

                return incomeStatementCell
            }
        case 2:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Fiscal Period".localized
                titleCell.financialPeriod1.text = "\(fiscalPeriod1.time)"
                titleCell.financialPeriod2.text = "\(fiscalPeriod2.time)"
                return titleCell
            } else {
                let balanceSheetStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCompareCell

                balanceSheetStatementCell.financialDataLabel.text = balanceSheetStatementLabels[indexPath.row - 1].localized

                // 1
                balanceSheetStatementCell.financialDataTextField1.text = convertStringToCurrency(amount: balanceSheetStatementValues1[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row - 1]]!] ?? "")
                balanceSheetStatementCell.financialDataTextField1.placeholder = "Enter Value".localized
                balanceSheetStatementCell.financialDataTextField1.delegate = self
                balanceSheetStatementCell.financialDataTextField1.tag = 1

                // 2
                balanceSheetStatementCell.financialDataTextField2.text = convertStringToCurrency(amount: balanceSheetStatementValues2[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row - 1]]!] ?? "")
                balanceSheetStatementCell.financialDataTextField2.placeholder = "Enter Value".localized
                balanceSheetStatementCell.financialDataTextField2.delegate = self
                balanceSheetStatementCell.financialDataTextField2.tag = 2

                if isCorrectCurrency(textField: balanceSheetStatementCell.financialDataTextField1) {
                    balanceSheetStatementCell.financialDataTextField1.textColor = .black
                } else {
                    balanceSheetStatementCell.financialDataTextField1.textColor = .red
                }

                if isCorrectCurrency(textField: balanceSheetStatementCell.financialDataTextField2) {
                    balanceSheetStatementCell.financialDataTextField2.textColor = .black
                } else {
                    balanceSheetStatementCell.financialDataTextField2.textColor = .red
                }

                return balanceSheetStatementCell
            }
        case 3:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Fiscal Period".localized
                titleCell.financialPeriod1.text = "\(fiscalPeriod1.time)"
                titleCell.financialPeriod2.text = "\(fiscalPeriod2.time)"
                return titleCell
            } else {
                let cashFlowStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCompareCell

                cashFlowStatementCell.financialDataLabel.text = cashFlowStatementLabels[indexPath.row - 1].localized

                // 1
                cashFlowStatementCell.financialDataTextField1.text = convertStringToCurrency(amount: cashFlowStatementValues1[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row - 1]]!] ?? "")
                cashFlowStatementCell.financialDataTextField1.placeholder = "Enter Value".localized
                cashFlowStatementCell.financialDataTextField1.delegate = self
                cashFlowStatementCell.financialDataTextField1.tag = 1

                // 2
                cashFlowStatementCell.financialDataTextField2.text = convertStringToCurrency(amount: cashFlowStatementValues2[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row - 1]]!] ?? "")
                cashFlowStatementCell.financialDataTextField2.placeholder = "Enter Value".localized
                cashFlowStatementCell.financialDataTextField2.delegate = self
                cashFlowStatementCell.financialDataTextField2.tag = 2

                if isCorrectCurrency(textField: cashFlowStatementCell.financialDataTextField1) {
                    cashFlowStatementCell.financialDataTextField1.textColor = .black
                } else {
                    cashFlowStatementCell.financialDataTextField1.textColor = .red
                }

                if isCorrectCurrency(textField: cashFlowStatementCell.financialDataTextField2) {
                    cashFlowStatementCell.financialDataTextField2.textColor = .black
                } else {
                    cashFlowStatementCell.financialDataTextField2.textColor = .red
                }

                return cashFlowStatementCell
            }
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        switch indexPath.section {
        case 0:
            let companyTableViewController = CompanyController()
            companyTableViewController.previousController = self
            navigationController?.pushViewController(companyTableViewController, animated: true)

        default:
            break
        }
    }
}

// MARK: UITextFieldDelegate

extension CompareController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .black

        let currency = convertStringToCurrency(amount: textField.text ?? "")

        if isCorrectCurrency(textField: textField) {
            textField.text = currency
        } else {
            textField.textColor = .red
        }

        if textField.tag == 1 {
            if let cell = textField.superview?.superview as? FinancialStatementCompareCell {
                let indexPath = tableView.indexPath(for: cell)
                switch indexPath?.section {
                case 1:
                    incomeStatementValues1[incomeStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                case 2:
                    balanceSheetStatementValues1[balanceSheetStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                case 3:
                    cashFlowStatementValues1[cashFlowStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                default:
                    break
                }
            }
        } else {
            if let cell = textField.superview?.superview as? FinancialStatementCompareCell {
                let indexPath = tableView.indexPath(for: cell)
                switch indexPath?.section {
                case 1:
                    incomeStatementValues2[incomeStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                case 2:
                    balanceSheetStatementValues2[balanceSheetStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                case 3:
                    cashFlowStatementValues2[cashFlowStatementAPI[indexPath!.row - 1]] = textField.text ?? ""
                default:
                    break
                }
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }

    func isCorrectCurrency(textField: UITextField) -> Bool {
        let currency = convertStringToCurrency(amount: textField.text ?? "")

        guard let _ = convertCurrencyToDouble(input: currency) else {
            return false
        }

        return true
    }
}

// MARK: - CreateNewControllerDelegate

extension CompareController: CreateNewControllerDelegate {
    func didCreateNew() {
        cancelfetchStatementCompareTask()
        tableView.refreshControl?.removeTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.refreshControl = nil
        hideHeaderIndictors(headerViews: headerViews)
        reloadCompany()
        tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
        tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .automatic)
        tableView.reloadSections(IndexSet(arrayLiteral: 3), with: .automatic)
    }
}

// MARK: - FinancialTimeTableViewDelegate

extension CompareController: FiscalPeriodControllerDelegate {
    func didSelectedFiscalPeriod() {
        cancelfetchStatementCompareTask()
        if isCompareFetchOnlineData {
            reloadCompany()
            setupRefresh()
            fetchFinancialDatas()
        } else {
            tableView.refreshControl?.removeTarget(self, action: #selector(refresh), for: .valueChanged)
            tableView.refreshControl = nil
            hideHeaderIndictors(headerViews: headerViews)
            reloadCompany()
            tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
            tableView.reloadSections(IndexSet(arrayLiteral: 2), with: .automatic)
            tableView.reloadSections(IndexSet(arrayLiteral: 3), with: .automatic)
        }
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension CompareController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(presentedViewController: presented, presenting: presenting)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(isPresenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator(isPresenting: false)
    }
}

extension CompareController: RatioCompareControllerDelegate {
    func RatioCompareControllerDidDismiss() {
        print("RatioCompareControllerDidDismiss")
        #if !targetEnvironment(macCatalyst)
            if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
            } else {
                if InterstitialAdsRequestHelper.increaseRequestAndCheckLoadInterstitialAd() {
                    GADInterstitialAd.load(withAdUnitID: Constants.interstitialAdID, request: GADRequest()) { ad, error in
                        if let error = error {
                            print("Failed to load interstitial ad with error: \(error.localizedDescription)")
                            return
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            if let ad = ad {
                                ad.present(fromRootViewController: self)
                                InterstitialAdsRequestHelper.resetRequestCount()
                            } else {
                                print("interstitial Ad wasn't ready")
                            }
                        }
                    }
                }
            }
        #endif
    }
}

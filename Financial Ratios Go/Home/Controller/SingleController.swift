//
//  SingleController.swift
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

class SingleController: FRGViewController {
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

        tableView.register(CompanySelectedCell.self, forCellReuseIdentifier: "CompanySelectedCell")
        tableView.register(FinancialStatementCell.self, forCellReuseIdentifier: "DataCell")

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

        setupViews()

        setupCalculateButton()

        fetchFinancialDatas()

        #if !targetEnvironment(macCatalyst)
            NotificationCenter.default.addObserver(self, selector: #selector(handlePurchaseNotification(_:)), name: .IAPHelperPurchaseNotification, object: nil)
        #endif
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        isSingle = true
        setupCalculateButton()
        if isHomeFetchOnlineData {
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

        let shareButton = UIButton(type: .custom)
        shareButton.snp.makeConstraints { make in
            make.height.width.equalTo(21)
        }
        shareButton.setImage(UIImage(named: "share-square-solid"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareSingleStatement(_:)), for: .touchUpInside)

        tabBarController?.navigationItem.rightBarButtonItems = [UIBarButtonItem(image: #imageLiteral(resourceName: "plus").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(addCompanyAndTime)), UIBarButtonItem(customView: shareButton)]

        let button = UIButton(type: .custom)
        button.snp.makeConstraints { make in
            make.size.equalTo(44)
        }
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.setImage(UIImage(named: "bars-solid"), for: .normal)
        button.addTarget(self, action: #selector(presentMenuController), for: .touchUpInside)

        tabBarController?.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
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
        FinancialStatement.initializeFinancialStatement()
        tableView.reloadData()
        beginfetchFinancialDatas()
    }

    fileprivate func beginfetchFinancialDatas() {
        showLoading(headerViews: headerViews)

        let fetchPlaces = ["income-statement", "balance-sheet-statement", "cash-flow-statement"]

        for i in 0 ... fetchPlaces.count - 1 {
            if !readStatmentFromLocal(company: company, fiscalPeriod: fiscalPeriod, statementName: fetchPlaces[i]) {
                fetchStatement(which: fetchPlaces[i]) { result in
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
            if readStatmentFromLocal(company: company, fiscalPeriod: fiscalPeriod, statementName: fetchPlaces[i]) {
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

extension SingleController {
    #if !targetEnvironment(macCatalyst)
        @objc func handlePurchaseNotification(_ notification: Notification) {
            bannerView.removeFromSuperview()
        }
    #endif

    @objc func shareSingleStatement(_ sender: UIButton) {
        print("shareSingleStatement")
        var str: String = ""

        str += "\("Company".localized):\t\(company.name) (\(company.symbol))\n"

        str += "\("Fiscal Period".localized):\t\(fiscalPeriod.time) (\(fiscalPeriod.period.localized))\n"

        str += "\n"

        str += "\("Income Statement".localized):\n"

        for i in 0 ... incomeStatementLabels.count - 1 {
            let resultStringValue = incomeStatementValues[incomeStatementLabelsMapping[incomeStatementLabels[i]]!] ?? ""
            str += "\(incomeStatementLabels[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        str += "\("Balance Sheet Statement".localized):\n"

        for i in 0 ... balanceSheetStatementLabels.count - 1 {
            let resultStringValue = balanceSheetStatementValues[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!] ?? ""
            str += "\(balanceSheetStatementLabels[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        str += "\("Cash Flow Statement".localized):\n"

        for i in 0 ... cashFlowStatementLabels.count - 1 {
            let resultStringValue = cashFlowStatementValues[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!] ?? ""
            str += "\(cashFlowStatementLabels[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        let file = getDocumentsDirectory().appendingPathComponent("\("Financial Statements".localized) \(company.symbol) \(fiscalPeriod.time).txt")

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

        FinancialRatio.initializeFinancialRatio()

        // Income statement

        let revenueString = incomeStatementValues["revenue"]
        let operatingIncomeString = incomeStatementValues["operatingIncome"]
        let EBITString = incomeStatementValues["ebitda"]
        let interestExpenseString = incomeStatementValues["interestExpense"]
        let incomeTaxExpenseString = incomeStatementValues["incomeTaxExpense"]
        let netIncomeString = incomeStatementValues["netIncome"]

        let revenue = convertCurrencyToDouble(input: revenueString ?? "")
        let operatingIncome = convertCurrencyToDouble(input: operatingIncomeString ?? "")
        let EBIT = convertCurrencyToDouble(input: EBITString ?? "")
        let interestExpense = convertCurrencyToDouble(input: interestExpenseString ?? "")
        let incomeTaxExpense = convertCurrencyToDouble(input: incomeTaxExpenseString ?? "")
        let netIncome = convertCurrencyToDouble(input: netIncomeString ?? "")

        // balance sheet statement

        let cashAndCashEquivalentsString = balanceSheetStatementValues["cashAndCashEquivalents"]
        let shortTermInvestmentsString = balanceSheetStatementValues["shortTermInvestments"]
        let receivablesString = balanceSheetStatementValues["netReceivables"]
        let totalCurrentAssetsString = balanceSheetStatementValues["totalCurrentAssets"]
        let totalAssetsString = balanceSheetStatementValues["totalAssets"]
        let shortTermDebtString = balanceSheetStatementValues["shortTermDebt"]
        let longTermDebtString = balanceSheetStatementValues["longTermDebt"]
        let totalCurrentLiabilitiesString = balanceSheetStatementValues["totalCurrentLiabilities"]
        let totalLiabilitiesString = balanceSheetStatementValues["totalLiabilities"]
        let totalShareholdersEquityString = balanceSheetStatementValues["totalStockholdersEquity"]

        let cashAndCashEquivalents = convertCurrencyToDouble(input: cashAndCashEquivalentsString ?? "")
        let shortTermInvestments = convertCurrencyToDouble(input: shortTermInvestmentsString ?? "")
        let receivables = convertCurrencyToDouble(input: receivablesString ?? "")
        let totalCurrentAssets = convertCurrencyToDouble(input: totalCurrentAssetsString ?? "")
        let totalAssets = convertCurrencyToDouble(input: totalAssetsString ?? "")
        let shortTermDebt = convertCurrencyToDouble(input: shortTermDebtString ?? "")
        let longTermDebt = convertCurrencyToDouble(input: longTermDebtString ?? "")
        let totalCurrentLiabilities = convertCurrencyToDouble(input: totalCurrentLiabilitiesString ?? "")
        let totalLiabilities = convertCurrencyToDouble(input: totalLiabilitiesString ?? "")
        let totalShareholdersEquity = convertCurrencyToDouble(input: totalShareholdersEquityString ?? "")

        // cash flow statement

        let operatingCashFlowString = cashFlowStatementValues["operatingCashFlow"]
        let dividendPaymentsString = cashFlowStatementValues["dividendsPaid"]
        let freeCashFlowString = cashFlowStatementValues["freeCashFlow"]

        let operatingCashFlow = convertCurrencyToDouble(input: operatingCashFlowString ?? "")
        let dividendPayments = convertCurrencyToDouble(input: dividendPaymentsString ?? "")
        let freeCashFlow = convertCurrencyToDouble(input: freeCashFlowString ?? "")

        // calculate formulas

        // MARK: liquidity Measurement Ratios

        // currentRatio = totalCurrentAssets/totalCurrentLiabilities
        if let totalCurrentAssets = totalCurrentAssets, let totalCurrentLiabilities = totalCurrentLiabilities {
            let value = totalCurrentAssets / totalCurrentLiabilities
            liquidityMeasurementRatiosValues["Current Ratio"] = String(value)
            financialRatioActualNumbers["Current Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = \(totalCurrentAssetsString!) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        } else {
            liquidityMeasurementRatiosValues["Current Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Current Ratio".localized] = "Wrong input values = \(totalCurrentAssetsString!) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        }

        // cashRatio = cashAndCashEquivalents / totalCurrentLiabilities
        if let cashAndCashEquivalents = cashAndCashEquivalents, let totalCurrentLiabilities = totalCurrentLiabilities {
            let value = cashAndCashEquivalents / totalCurrentLiabilities
            liquidityMeasurementRatiosValues["Cash Ratio"] = String(value)
            financialRatioActualNumbers["Cash Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = \(cashAndCashEquivalentsString!) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        } else {
            liquidityMeasurementRatiosValues["Cash Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Cash Ratio".localized] = "Wrong input values = \(cashAndCashEquivalentsString!) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        }

        // Acid-test Ratio = (Cash and Cash Equivalents + Short-term Investments + Receivables) / Total Current Liabilities
        if let cashAndCashEquivalents = cashAndCashEquivalents, let shortTermInvestments = shortTermInvestments, let receivables = receivables, let totalCurrentLiabilities = totalCurrentLiabilities {
            let value = (cashAndCashEquivalents + shortTermInvestments + receivables) / totalCurrentLiabilities
            liquidityMeasurementRatiosValues["Acid-Test Ratio"] = String(value)
            financialRatioActualNumbers["Acid-Test Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = (\(cashAndCashEquivalentsString!)+\(shortTermInvestmentsString!)+\(receivablesString!)) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        } else {
            liquidityMeasurementRatiosValues["Acid-Test Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Acid-Test Ratio".localized] = "Wrong input values = (\(cashAndCashEquivalentsString!)+\(shortTermInvestmentsString!)+\(receivablesString!)) / \(totalCurrentLiabilitiesString!) ⨉ 100%"
        }

        // MARK: Debt Ratios

        // debtRatio = (shortTermDebt + longTermDebt) / totalAssets
        if let shortTermDebt = shortTermDebt, let longTermDebt = longTermDebt, let totalAssets = totalAssets {
            let value = (shortTermDebt + longTermDebt) / totalAssets
            debtRatiosValues["Debt Ratio"] = String(value)
            financialRatioActualNumbers["Debt Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = (\(shortTermDebtString!)+\(longTermDebtString!)) / \(totalAssetsString!) ⨉ 100%"
        } else {
            debtRatiosValues["Debt Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Debt Ratio".localized] = "Wrong input values = (\(shortTermDebtString!)+\(longTermDebtString!)) / \(totalAssetsString!) ⨉ 100%"
        }

        // interestCoverage = EBIT / interestExpense
        if let EBIT = EBIT, let interestExpense = interestExpense {
            let value = EBIT / interestExpense
            debtRatiosValues["Interest Coverage"] = String(value)
            financialRatioActualNumbers["Interest Coverage".localized] = "\(String(format: "%.2f%%", value * 100)) = \(EBITString!) / \(interestExpenseString!) ⨉ 100%"
        } else {
            debtRatiosValues["Interest Coverage"] = "Wrong input values".localized
            financialRatioActualNumbers["Interest Coverage".localized] = "Wrong input values = \(EBITString!) / \(interestExpenseString!) ⨉ 100%"
        }

        // cashFlowToDebtRatio = operatingCashFlow / (shortTermDebt + longTermDebt)
        if let operatingCashFlow = operatingCashFlow, let shortTermDebt = shortTermDebt, let longTermDebt = longTermDebt {
            let value = operatingCashFlow / (shortTermDebt + longTermDebt)
            debtRatiosValues["Cash Flow to Debt Ratio"] = String(value)
            financialRatioActualNumbers["Cash Flow to Debt Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = \(operatingCashFlowString!) / (\(shortTermDebtString!)+\(longTermDebtString!)) ⨉ 100%"
        } else {
            debtRatiosValues["Cash Flow to Debt Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Cash Flow to Debt Ratio".localized] = "Wrong input values = \(operatingCashFlowString!) / (\(shortTermDebtString!)+\(longTermDebtString!)) ⨉ 100%"
        }

        // Debt to Equity Ratio = Total liabilities / Total Shareholders Equity
        if let totalLiabilities = totalLiabilities, let totalShareholdersEquity = totalShareholdersEquity {
            let value = totalLiabilities / totalShareholdersEquity
            debtRatiosValues["Debt to Equity Ratio"] = String(value)
            financialRatioActualNumbers["Debt to Equity Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = \(totalLiabilitiesString!) / \(totalShareholdersEquityString!) ⨉ 100%"
        } else {
            debtRatiosValues["Debt to Equity Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Debt to Equity Ratio".localized] = "Wrong input values = \(totalLiabilitiesString!) / \(totalShareholdersEquityString!) ⨉ 100%"
        }

        // Debt to Equity Ratio = Total Equity/ Total Assets
        if let totalShareholdersEquity = totalShareholdersEquity, let totalAssets = totalAssets {
            let value = totalShareholdersEquity / totalAssets
            debtRatiosValues["Equity Ratio"] = String(value)
            financialRatioActualNumbers["Equity Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = \(totalShareholdersEquityString!) / \(totalAssetsString!) ⨉ 100%"
        } else {
            debtRatiosValues["Equity Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Equity Ratio".localized] = "Wrong input values = \(totalShareholdersEquityString!) / \(totalAssetsString!) ⨉ 100%"
        }

        // MARK: profitability Indicator Ratios

        // operatingProfitMargin = operatingIncome / revenue
        if let operatingIncome = operatingIncome, let revenue = revenue {
            let value = operatingIncome / revenue
            profitabilityIndicatorRatiosValues["Operating Profit Margin"] = String(value)
            financialRatioActualNumbers["Operating Profit Margin".localized] = "\(String(format: "%.2f%%", value * 100)) = \(operatingIncomeString!) / \(revenueString!) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Operating Profit Margin"] = "Wrong input values".localized
            financialRatioActualNumbers["Operating Profit Margin".localized] = "Wrong input values = \(operatingIncomeString!) / \(revenueString!) ⨉ 100%"
        }

        // netProfitMargin = netIncome / revenue
        if let netIncome = netIncome, let revenue = revenue {
            let value = netIncome / revenue
            profitabilityIndicatorRatiosValues["Net Profit Margin"] = String(value)
            financialRatioActualNumbers["Net Profit Margin".localized] = "\(String(format: "%.2f%%", value * 100)) = \(netIncomeString!) / \(revenueString!) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Net Profit Margin"] = "Wrong input values".localized
            financialRatioActualNumbers["Net Profit Margin".localized] = "Wrong input values = \(netIncomeString!) / \(revenueString!) ⨉ 100%"
        }

        // Return on Equity = Net Income / Total Shareholders Equity
        if let netIncome = netIncome, let totalShareholdersEquity = totalShareholdersEquity {
            let value = netIncome / totalShareholdersEquity
            profitabilityIndicatorRatiosValues["Return on Equity"] = String(value)
            financialRatioActualNumbers["Return on Equity".localized] = "\(String(format: "%.2f%%", value * 100)) = \(netIncomeString!) / \(totalShareholdersEquityString!) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Return on Equity"] = "Wrong input values".localized
            financialRatioActualNumbers["Return on Equity".localized] = "Wrong input values = \(netIncomeString!) / \(totalShareholdersEquityString!) ⨉ 100%"
        }

        // returnOnDebt = netIncome / longTermDebt
        if let netIncome = netIncome, let longTermDebt = longTermDebt {
            let value = netIncome / longTermDebt
            profitabilityIndicatorRatiosValues["Return on Debt"] = String(value)
            financialRatioActualNumbers["Return on Debt".localized] = "\(String(format: "%.2f%%", value * 100)) = \(netIncomeString!) / \(longTermDebtString!) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Return on Debt"] = "Wrong input values".localized
            financialRatioActualNumbers["Return on Debt".localized] = "Wrong input values = \(netIncomeString!) / \(longTermDebtString!) ⨉ 100%"
        }

        // returnOnInvestedCaptial = (operatingIncome - taxExpense) / (longTermDebt + totalShareholdersEquity - cashAndCashEquivalents)

        if let operatingIncome = operatingIncome, let incomeTaxExpense = incomeTaxExpense, let longTermDebt = longTermDebt, let totalShareholdersEquity = totalShareholdersEquity, let cashAndCashEquivalents = cashAndCashEquivalents {
            let value = (operatingIncome - incomeTaxExpense) / (longTermDebt + totalShareholdersEquity - cashAndCashEquivalents)
            profitabilityIndicatorRatiosValues["Return on Invested Capital"] = String(value)
            financialRatioActualNumbers["Return on Invested Capital".localized] = "\(String(format: "%.2f%%", value * 100)) = (\(operatingIncomeString!)\("-")\(incomeTaxExpenseString!)) / (\(longTermDebtString!)\("+")\(totalShareholdersEquityString!)\("-")\(cashAndCashEquivalentsString!)) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Return on Invested Capital"] = "Wrong input values".localized
            financialRatioActualNumbers["Return on Invested Capital".localized] = "Wrong input values = (\(operatingIncomeString!)\("-")\(incomeTaxExpenseString!)) / (\(longTermDebtString!)\("+")\(totalShareholdersEquityString!)\("-")\(cashAndCashEquivalentsString!)) ⨉ 100%"
        }

        // Return on Capital Employed (ROCE) = Operating Income / (Total Assets - Total Current Liabilities)
        if let operatingIncome = operatingIncome, let totalAssets = totalAssets, let totalCurrentLiabilities = totalCurrentLiabilities {
            let value = operatingIncome / (totalAssets - totalCurrentLiabilities)
            profitabilityIndicatorRatiosValues["Return on Capital Employed"] = String(value)
            financialRatioActualNumbers["Return on Capital Employed".localized] = "\(String(format: "%.2f%%", value * 100)) = \(operatingIncomeString!) / (\(totalAssetsString!)-\(totalCurrentLiabilitiesString!)) ⨉ 100%"
        } else {
            profitabilityIndicatorRatiosValues["Return on Capital Employed"] = "Wrong input values".localized
            financialRatioActualNumbers["Return on Capital Employed".localized] = "Wrong input values = \(operatingIncomeString!) / (\(totalAssetsString!)-\(totalCurrentLiabilitiesString!)) ⨉ 100%"
        }

        // MARK: Cash Flow Indicator Ratios

        // CFROI = Operating Cash Flow/(Total Assets - Total Current Liabilities)
        if let operatingCashFlow = operatingCashFlow, let totalAssets = totalAssets, let totalCurrentLiabilities = totalCurrentLiabilities {
            let value = operatingCashFlow / (totalAssets - totalCurrentLiabilities)
            cashFlowIndicatorRatiosValues["CFROI"] = String(value)
            financialRatioActualNumbers["CFROI".localized] = "\(String(format: "%.2f%%", value * 100)) = \(operatingCashFlowString!) / (\(totalAssetsString!)-\(totalCurrentLiabilitiesString!)) ⨉ 100%"
        } else {
            cashFlowIndicatorRatiosValues["CFROI"] = "Wrong input values".localized
            financialRatioActualNumbers["CFROI".localized] = "Wrong input values = \(operatingCashFlowString!) / (\(totalAssetsString!)+\(totalCurrentLiabilitiesString!)) ⨉ 100%"
        }

        // dividentPayoutRatio = dividendPayments / netIncome
        if let dividendPayments = dividendPayments, let netIncome = netIncome {
            let value = fabs(dividendPayments / netIncome)
            cashFlowIndicatorRatiosValues["Dividend Payout Ratio"] = String(value)
            financialRatioActualNumbers["Dividend Payout Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = |\(dividendPaymentsString!) / \(netIncomeString!)| ⨉ 100%"
        } else {
            cashFlowIndicatorRatiosValues["Dividend Payout Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Dividend Payout Ratio".localized] = "Wrong input values = |\(dividendPaymentsString!) / \(netIncomeString!)| ⨉ 100%"
        }

        // Free Cash Flow-To-Sales = Free Cash Flow / Revenue
        if let freeCashFlow = freeCashFlow, let revenue = revenue {
            let value = freeCashFlow / revenue
            cashFlowIndicatorRatiosValues["Free Cash Flow-To-Sales"] = String(value)
            financialRatioActualNumbers["Free Cash Flow-To-Sales".localized] = "\(String(format: "%.2f%%", value * 100)) = \(freeCashFlowString!) / \(revenueString!) ⨉ 100%"
        } else {
            cashFlowIndicatorRatiosValues["Free Cash Flow-To-Sales"] = "Wrong input values".localized
            financialRatioActualNumbers["Free Cash Flow-To-Sales".localized] = "Wrong input values = \(freeCashFlowString!) / \(revenueString!) ⨉ 100%"
        }

        // Retention Ratio = (Net Income - |Dividend Payments|) / Net Income
        if let netIncome = netIncome, let dividendPayments = dividendPayments {
            let value = (netIncome - fabs(dividendPayments)) / netIncome
            cashFlowIndicatorRatiosValues["Retention Ratio"] = String(value)
            financialRatioActualNumbers["Retention Ratio".localized] = "\(String(format: "%.2f%%", value * 100)) = (\(netIncomeString!)-|\(dividendPaymentsString!)|) / \(netIncomeString!) ⨉ 100%"
        } else {
            cashFlowIndicatorRatiosValues["Retention Ratio"] = "Wrong input values".localized
            financialRatioActualNumbers["Retention Ratio".localized] = "Wrong input values = (\(netIncomeString!)-|\(dividendPaymentsString!)|) / \(netIncomeString!) ⨉ 100%"
        }

        let RatioResultVC = RatioResultController()
        RatioResultVC.delegate = self

        let navController = FRGNavigationController(rootViewController: RatioResultVC)

        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true, completion: nil)
    }
}

// MARK: MenuControllerDelegate

extension SingleController: MenuControllerDelegate {
    func didChangeLanguage() {
        financialRatioActualNumbers = [
            "Current Ratio".localized: "",
            "Cash Ratio".localized: "",
            "Debt Ratio".localized: "",
            "Interest Coverage".localized: "",
            "Operating Profit Margin".localized: "",
            "Net Profit Margin".localized: "",
            "Return on Equity".localized: "",
            "Dividend Payout Ratio".localized: "",
            "Return on Debt".localized: "",
            "Cash Flow to Debt Ratio".localized: "",
            "CFROI".localized: "",
            "Return on Invested Capital".localized: "",
            "Acid-Test Ratio".localized: "",
            "Debt to Equity Ratio".localized: "",
            "Equity Ratio".localized: "",
            "Return on Capital Employed".localized: "",
            "Free Cash Flow-To-Sales".localized: "",
            "Retention Ratio".localized: "",
        ]

        tabBarController?.title = "Financial Statements".localized
        setupCalculateButton()
        tabBarController?.viewControllers?[0].tabBarItem.title = "Financial Ratios".localized
        tabBarController?.viewControllers?[1].tabBarItem.title = "Statement Compare".localized
        tabBarController?.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
        if isHomeFetchOnlineData {
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

extension SingleController: UITableViewDataSource, UITableViewDelegate {
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
            return incomeStatementLabels.count
        case 2:
            return balanceSheetStatementLabels.count
        case 3:
            return cashFlowStatementLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return companyRowHeight
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
            let companyCell = tableView.dequeueReusableCell(withIdentifier: "CompanySelectedCell", for: indexPath) as! CompanySelectedCell
            companyCell.accessoryType = .disclosureIndicator

            companyCell.companyIconView.image = UIImage(data: company.logoImage)
            companyCell.companyNameAndCodeLabel.text = "\(company.name) (\(company.symbol))"
            companyCell.financialTime.text = "\(fiscalPeriod.time) (\(fiscalPeriod.period.localized))"

            return companyCell
        case 1:
            let incomeStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            incomeStatementCell.financialDataLabel.text = incomeStatementLabels[indexPath.row].localized
            incomeStatementCell.financialDataTextField.text = convertStringToCurrency(amount: incomeStatementValues[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row]]!] ?? "")
            incomeStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            incomeStatementCell.financialDataTextField.delegate = self

            if isCorrectCurrency(textField: incomeStatementCell.financialDataTextField) {
                incomeStatementCell.financialDataTextField.textColor = .black
            } else {
                incomeStatementCell.financialDataTextField.textColor = .red
            }

            return incomeStatementCell
        case 2:
            let balanceSheetStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            balanceSheetStatementCell.financialDataLabel.text = balanceSheetStatementLabels[indexPath.row].localized
            balanceSheetStatementCell.financialDataTextField.text = convertStringToCurrency(amount: balanceSheetStatementValues[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row]]!] ?? "")
            balanceSheetStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            balanceSheetStatementCell.financialDataTextField.delegate = self

            if isCorrectCurrency(textField: balanceSheetStatementCell.financialDataTextField) {
                balanceSheetStatementCell.financialDataTextField.textColor = .black
            } else {
                balanceSheetStatementCell.financialDataTextField.textColor = .red
            }

            return balanceSheetStatementCell
        case 3:
            let cashFlowStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            cashFlowStatementCell.financialDataLabel.text = cashFlowStatementLabels[indexPath.row].localized
            cashFlowStatementCell.financialDataTextField.text = convertStringToCurrency(amount: cashFlowStatementValues[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row]]!] ?? "")
            cashFlowStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            cashFlowStatementCell.financialDataTextField.delegate = self

            if isCorrectCurrency(textField: cashFlowStatementCell.financialDataTextField) {
                cashFlowStatementCell.financialDataTextField.textColor = .black
            } else {
                cashFlowStatementCell.financialDataTextField.textColor = .red
            }

            return cashFlowStatementCell
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

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FinancialStatementCell

        explainBox.setContent(title: cell.financialDataLabel.text!, message: ExplainModel().financialStatementExplain[cell.financialDataLabel.text!]!)

        present(explainBox, animated: false, completion: nil)
    }
}

// MARK: UITextFieldDelegate

extension SingleController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .black

        let currency = convertStringToCurrency(amount: textField.text ?? "")

        if isCorrectCurrency(textField: textField) {
            textField.text = currency
        } else {
            textField.textColor = .red
        }

        if let cell = textField.superview?.superview as? FinancialStatementCell {
            let indexPath = tableView.indexPath(for: cell)
            switch indexPath?.section {
            case 1:
                incomeStatementValues[incomeStatementAPI[indexPath!.row]] = textField.text ?? ""
            case 2:
                balanceSheetStatementValues[balanceSheetStatementAPI[indexPath!.row]] = textField.text ?? ""
            case 3:
                cashFlowStatementValues[cashFlowStatementAPI[indexPath!.row]] = textField.text ?? ""
            default:
                break
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

extension SingleController: CreateNewControllerDelegate {
    func didCreateNew() {
        cancelfetchStatementTask()
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

extension SingleController: FiscalPeriodControllerDelegate {
    func didSelectedFiscalPeriod() {
        cancelfetchStatementTask()
        if isHomeFetchOnlineData {
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

extension SingleController: UIViewControllerTransitioningDelegate {
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

extension SingleController: RatioResultControllerDelegate {
    func RatioResultControllerDidDismiss() {
        print("RatioResultControllerDidDismiss")
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
                            ad.present(fromRootViewController: self)
                            InterstitialAdsRequestHelper.resetRequestCount()
                        } else {
                            print("interstitial Ad wasn't ready")
                        }
                    }
                }
            }
        #endif
    }
}

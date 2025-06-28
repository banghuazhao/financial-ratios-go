//
//  ResultCompareController.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/22/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

protocol RatioCompareControllerDelegate: AnyObject {
    func RatioCompareControllerDidDismiss()
}

class ResultCompareController: FRGViewController {
    weak var delegate: RatioCompareControllerDelegate?

    var headerViews: [FRGHeaderView] = {
        var headerViews: [FRGHeaderView] = []
        for (section, homeSectionHeader) in homeSectionHeaders.enumerated() {
            let headerView = FRGHeaderView()
            headerView.sectionTitle = homeSectionHeader.title.localized
            headerView.isStatic = true
            headerView.section = section
            headerViews.append(headerView)
        }
        return headerViews
    }()

    var cellNumAnimationMask = [
        Array(repeating: 0, count: incomeStatementValues.count),
        Array(repeating: 0, count: balanceSheetStatementValues.count),
        Array(repeating: 0, count: cashFlowStatementValues.count),
    ]

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        tableView.register(CompanySelectedCompareCell.self, forCellReuseIdentifier: "CompanySelectedCell")
        tableView.register(FinancialStatementTitleCell.self, forCellReuseIdentifier: "TitleCell")
        tableView.register(ResultCompareCell.self, forCellReuseIdentifier: "ResultCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .backgroundColor

        return tableView
    }()

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
        setupNav()
        setupViews()
        StoreReviewHelper.incrementCalculateCount()
        StoreReviewHelper.checkAndAskForReview()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        delegate?.RatioCompareControllerDidDismiss()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func setupNav() {
        setupCancelButton()
        let button = UIButton(type: .custom)
        button.snp.makeConstraints { make in
            make.height.width.equalTo(21)
        }
        button.setImage(UIImage(named: "share-square-solid"), for: .normal)
        button.addTarget(self, action: #selector(shareResult(_:)), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        navigationItem.title = "Statement Compare".localized
    }

    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
}

// MARK: actions

extension ResultCompareController {
    @objc func shareResult(_ sender: UIButton) {
        var str: String = ""

        str += "\("Company".localized):\t\(compareCompany.name) (\(compareCompany.symbol))\n"

        str += "\("Fiscal Period".localized) 1:\t\(fiscalPeriod1.time) (\(fiscalPeriod1.period.localized))\n"
        str += "\("Fiscal Period".localized) 2:\t\(fiscalPeriod2.time) (\(fiscalPeriod2.period.localized))\n"

        str += "\n"

        str += "\("Income Statement".localized)\t\(fiscalPeriod1.time)\t\(fiscalPeriod2.time)\t\("Amount".localized)\t\("Percent".localized)\n"

        for i in 0 ... incomeStatementLabels.count - 1 {
            let statementValue1 = incomeStatementValues1[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!
            let statementValue2 = incomeStatementValues2[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!

            let resultStringValue1 = incomeStatementValuesCompare1[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!

            var resultStringValue2 = incomeStatementValuesCompare2[incomeStatementLabelsMapping[incomeStatementLabels[i]]!]!
            if resultStringValue2 != "inf" {
                if let doubleValue = Double(resultStringValue2) {
                    resultStringValue2 = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(incomeStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\t\(resultStringValue1)\t\(resultStringValue2)\n"
        }

        str += "\n"

        str += "\("balance Sheet Statement".localized)\t\(fiscalPeriod1.time)\t\(fiscalPeriod2.time)\t\("Amount".localized)\t\("Percent".localized)\n"

        for i in 0 ... balanceSheetStatementLabels.count - 1 {
            let statementValue1 = balanceSheetStatementValues1[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!
            let statementValue2 = balanceSheetStatementValues2[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!

            let resultStringValue1 = balanceSheetStatementValuesCompare1[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!

            var resultStringValue2 = balanceSheetStatementValuesCompare2[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[i]]!]!
            if resultStringValue2 != "inf" {
                if let doubleValue = Double(resultStringValue2) {
                    resultStringValue2 = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(balanceSheetStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\t\(resultStringValue1)\t\(resultStringValue2)\n"
        }

        str += "\n"

        str += "\("Cash Flow Statement".localized)\t\(fiscalPeriod1.time)\t\(fiscalPeriod2.time)\t\("Amount".localized)\t\("Percent".localized)\n"

        for i in 0 ... cashFlowStatementLabels.count - 1 {
            let statementValue1 = cashFlowStatementValues1[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!
            let statementValue2 = cashFlowStatementValues2[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!

            let resultStringValue1 = cashFlowStatementValuesCompare1[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!

            var resultStringValue2 = cashFlowStatementValuesCompare2[cashFlowStatementLabelsMapping[cashFlowStatementLabels[i]]!]!
            if resultStringValue2 != "inf" {
                if let doubleValue = Double(resultStringValue2) {
                    resultStringValue2 = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(cashFlowStatementLabels[i].localized)\t\(statementValue1)\t\(statementValue2)\t\(resultStringValue1)\t\(resultStringValue2)\n"
        }

        str += "\n"

        let file = getDocumentsDirectory().appendingPathComponent("\("Financial Ratios Compare".localized) \(company.symbol) \(fiscalPeriod1.time) vs \(fiscalPeriod2.time).txt")

        do {
            try str.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch let err {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("Error when create statement_compare.txt: \(err)")
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
}

// MARK: table view delegate and data source

extension ResultCompareController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()

        if section == 3 {
            #if !targetEnvironment(macCatalyst)
                if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                    print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
                } else {
                    footerView.addSubview(bannerView)
                    bannerView.snp.makeConstraints { make in
                        make.height.equalTo(250)
                        make.left.right.equalToSuperview().inset(dataRowLeftRightSpace)
                        make.top.equalToSuperview().offset(sectionHeight)
                    }
                }
            #endif
        }

        return footerView
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return homeSectionHeaders.count
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 3 {
            return 250
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let companyCell = tableView.dequeueReusableCell(withIdentifier: "CompanySelectedCell", for: indexPath) as! CompanySelectedCompareCell
            companyCell.selectionStyle = .none

            companyCell.companyIconView.image = UIImage(data: compareCompany.logoImage)
            companyCell.companyNameAndCodeLabel.text = "\(compareCompany.name) (\(compareCompany.symbol))"
            companyCell.financialTime1.text = "\(fiscalPeriod1.time) (\(fiscalPeriod1.period.localized))"
            companyCell.financialTime2.text = "\(fiscalPeriod2.time) (\(fiscalPeriod2.period.localized))"

            return companyCell
        case 1:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Increase or Decrease".localized
                titleCell.financialPeriod1.text = "Amount".localized
                titleCell.financialPeriod2.text = "Percent".localized
                return titleCell
            } else {
                let incomeStatementCell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCompareCell

                incomeStatementCell.resultDataLabel.text = incomeStatementLabels[indexPath.row - 1].localized

                // 1
                incomeStatementCell.resultDataValue1.text = convertStringToCurrency(amount: incomeStatementValuesCompare1[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row - 1]]!] ?? "")

                // 2
                incomeStatementCell.resultDataValue2.text = incomeStatementValuesCompare2[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row - 1]]!]

                return incomeStatementCell
            }
        case 2:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Increase or Decrease".localized
                titleCell.financialPeriod1.text = "Amount".localized
                titleCell.financialPeriod2.text = "Percent".localized
                return titleCell
            } else {
                let balanceSheetStatementCell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCompareCell

                balanceSheetStatementCell.resultDataLabel.text = balanceSheetStatementLabels[indexPath.row - 1].localized

                // 1
                balanceSheetStatementCell.resultDataValue1.text = convertStringToCurrency(amount: balanceSheetStatementValuesCompare1[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row - 1]]!] ?? "")

                // 2
                balanceSheetStatementCell.resultDataValue2.text = balanceSheetStatementValuesCompare2[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row - 1]]!]

                return balanceSheetStatementCell
            }
        case 3:
            if indexPath.row == 0 {
                let titleCell = tableView.dequeueReusableCell(withIdentifier: "TitleCell", for: indexPath) as! FinancialStatementTitleCell
                titleCell.financialTitleLabel.text = "Increase or Decrease".localized
                titleCell.financialPeriod1.text = "Amount".localized
                titleCell.financialPeriod2.text = "Percent".localized
                return titleCell
            } else {
                let cashFlowStatementCell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! ResultCompareCell

                cashFlowStatementCell.resultDataLabel.text = cashFlowStatementLabels[indexPath.row - 1].localized

                // 1
                cashFlowStatementCell.resultDataValue1.text = convertStringToCurrency(amount: cashFlowStatementValuesCompare1[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row - 1]]!] ?? "")

                // 2
                cashFlowStatementCell.resultDataValue2.text = cashFlowStatementValuesCompare2[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row - 1]]!]

                return cashFlowStatementCell
            }
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? ResultCompareCell else { return }
        setupDataDisplay(cell: cell, indexPath: indexPath)
    }

    func setupDataDisplay(cell: ResultCompareCell, indexPath: IndexPath) {
        if cell.resultDataValue1.text == "Wrong input values".localized || cell.resultDataValue1.text == "inf" {
            cell.resultDataValue1.textColor = .red
        } else {
            cell.resultDataValue1.textColor = .black
        }

        if cell.resultDataValue2.text == "Wrong input values".localized || cell.resultDataValue2.text == "inf" {
            cell.resultDataValue2.textColor = .red
        } else {
            cell.resultDataValue2.textColor = .black

            if let doubleValue = Double(cell.resultDataValue2.text!) {
                cell.resultDataValue2.setUpdateBlock { value, label in
                    label.text = String(format: "%.2f%%", value)
                }
                if cellNumAnimationMask[indexPath.section - 1][indexPath.row - 1] == 0 {
                    cellNumAnimationMask[indexPath.section - 1][indexPath.row - 1] = 1
                    cell.resultDataValue2.countFrom(0.0, to: CGFloat(doubleValue * 100), withDuration: 1.0)
                } else {
                    cell.resultDataValue2.countFrom(CGFloat(doubleValue * 100), to: CGFloat(doubleValue * 100), withDuration: 0.0)
                }
            }
        }
    }
}

//
//  RatioResult.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/22/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

protocol RatioResultControllerDelegate: AnyObject {
    func RatioResultControllerDidDismiss()
}

class RatioResultController: FRGViewController {
    weak var delegate: RatioResultControllerDelegate?

    let headerViews: [FRGHeaderView] = {
        var headerViews: [FRGHeaderView] = []
        for (section, homeSectionHeader) in resultSectionHeaders.enumerated() {
            let headerView = FRGHeaderView()
            headerView.sectionTitle = homeSectionHeader.title.localized
            headerView.isStatic = homeSectionHeader.isStatic
            headerView.section = section
            headerViews.append(headerView)
        }
        return headerViews
    }()

    var cellNumAnimationMask = [
        Array(repeating: 0, count: liquidityMeasurementRatiosLabel.count),
        Array(repeating: 0, count: debtRatiosLabel.count),
        Array(repeating: 0, count: profitabilityIndicatorRatiosLabel.count),
        Array(repeating: 0, count: cashFlowIndicatorRatiosLabel.count),
    ]

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        tableView.register(CompanySelectedCell.self, forCellReuseIdentifier: "CompanySelectedCell")
        tableView.register(RatioResultCell.self, forCellReuseIdentifier: "ResultCell")

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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("RatioResultControllerDidDismiss")
        delegate?.RatioResultControllerDidDismiss()
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
        navigationItem.title = "Financial Ratios".localized
    }

    private func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: actions

extension RatioResultController {
    @objc func shareResult(_ sender: UIButton) {
        var str: String = ""

        str += "\("Company".localized):\t\(company.name) (\(company.symbol))\n"

        str += "\("Fiscal Period".localized):\t\(fiscalPeriod.time) (\(fiscalPeriod.period.localized))\n"

        str += "\n"

        str += "\("Liquidity Measurement Ratios".localized):\n"

        for i in 0 ... liquidityMeasurementRatiosLabel.count - 1 {
            var resultStringValue = liquidityMeasurementRatiosValues[liquidityMeasurementRatiosLabel[i]]!
            if resultStringValue != "inf" {
                if let doubleValue = Double(resultStringValue) {
                    resultStringValue = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(liquidityMeasurementRatiosLabel[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        str += "\("Debt Ratios".localized):\n"

        for i in 0 ... debtRatiosLabel.count - 1 {
            var resultStringValue = debtRatiosValues[debtRatiosLabel[i]]!
            if resultStringValue != "inf" {
                if let doubleValue = Double(resultStringValue) {
                    resultStringValue = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(debtRatiosLabel[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        str += "\("Profit Ability Indicator Ratios".localized):\n"

        for i in 0 ... profitabilityIndicatorRatiosLabel.count - 1 {
            var resultStringValue = profitabilityIndicatorRatiosValues[profitabilityIndicatorRatiosLabel[i]]!
            if resultStringValue != "inf" {
                if let doubleValue = Double(resultStringValue) {
                    resultStringValue = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(profitabilityIndicatorRatiosLabel[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        str += "\("Cash Flow Indicator Ratios".localized):\n"

        for i in 0 ... cashFlowIndicatorRatiosLabel.count - 1 {
            var resultStringValue = cashFlowIndicatorRatiosValues[cashFlowIndicatorRatiosLabel[i]]!
            if resultStringValue != "inf" {
                if let doubleValue = Double(resultStringValue) {
                    resultStringValue = "\(String(format: "%.2f", doubleValue * 100))%"
                }
            }
            str += "\(cashFlowIndicatorRatiosLabel[i].localized)\t\(resultStringValue)\n"
        }

        str += "\n"

        let file = getDocumentsDirectory().appendingPathComponent("\("Financial Ratios".localized) \(company.symbol) \(fiscalPeriod.time).txt")

        do {
            try str.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch let err {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("Error when create Financial Ratios.txt: \(err)")
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

extension RatioResultController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 4 {
            return 250
        }
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()

        if section == 4 {
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return companyRowHeight
        default:
            return statementRowHeight
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return liquidityMeasurementRatiosLabel.count
        case 2:
            return debtRatiosLabel.count
        case 3:
            return profitabilityIndicatorRatiosLabel.count
        case 4:
            return cashFlowIndicatorRatiosLabel.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let companyCell = tableView.dequeueReusableCell(withIdentifier: "CompanySelectedCell", for: indexPath) as! CompanySelectedCell

            companyCell.companyIconView.image = UIImage(data: company.logoImage)
            companyCell.companyNameAndCodeLabel.text = "\(company.name) (\(company.symbol))"
            companyCell.financialTime.text = "\(fiscalPeriod.time) (\(fiscalPeriod.period.localized))"
            companyCell.selectionStyle = .none

            return companyCell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! RatioResultCell

            cell.resultDataLabel.text = liquidityMeasurementRatiosLabel[indexPath.row].localized
            cell.resultDataValue.text = liquidityMeasurementRatiosValues[liquidityMeasurementRatiosLabel[indexPath.row]]

            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! RatioResultCell

            cell.resultDataLabel.text = debtRatiosLabel[indexPath.row].localized
            cell.resultDataValue.text = debtRatiosValues[debtRatiosLabel[indexPath.row]]

            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! RatioResultCell

            cell.resultDataLabel.text = profitabilityIndicatorRatiosLabel[indexPath.row].localized
            cell.resultDataValue.text = profitabilityIndicatorRatiosValues[profitabilityIndicatorRatiosLabel[indexPath.row]]

            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ResultCell", for: indexPath) as! RatioResultCell

            cell.resultDataLabel.text = cashFlowIndicatorRatiosLabel[indexPath.row].localized
            cell.resultDataValue.text = cashFlowIndicatorRatiosValues[cashFlowIndicatorRatiosLabel[indexPath.row]]

            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? RatioResultCell else { return }
        setupDataDisplay(cell: cell, indexPath: indexPath)
    }

    func setupDataDisplay(cell: RatioResultCell, indexPath: IndexPath) {
        if cell.resultDataValue.text == "Wrong input values".localized || cell.resultDataValue.text == "inf" {
            cell.resultDataValue.textColor = .red
        } else {
            cell.resultDataValue.textColor = .black

            if let doubleValue = Double(cell.resultDataValue.text!) {
                cell.resultDataValue.setUpdateBlock { value, label in
                    label.text = String(format: "%.2f%%", value)
                }
                if cellNumAnimationMask[indexPath.section - 1][indexPath.row] == 0 {
                    cellNumAnimationMask[indexPath.section - 1][indexPath.row] = 1
                    cell.resultDataValue.countFrom(0.0, to: CGFloat(doubleValue * 100), withDuration: 1.0)
                } else {
                    cell.resultDataValue.countFrom(CGFloat(doubleValue * 100), to: CGFloat(doubleValue * 100), withDuration: 0.0)
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! RatioResultCell

        let explainItem = cell.resultDataLabel.text!

        var message = ExplainModel().financialRatioExplain[explainItem]!
        let actualNumbers = financialRatioActualNumbers[explainItem]!

        message = message.replacingOccurrences(of: "Reference", with: "\(actualNumbers)\n\nReference")

        explainBox.setContent(title: cell.resultDataLabel.text!, message: message)

        present(explainBox, animated: false, completion: nil)
    }
}

//
//  CompanyProfileController.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 12/14/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

import Kingfisher
import SkeletonView

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif

// struct CompanyProfile {
//    let image: UIImage
//    let companyName: String
//    let symbol: String
//    let website: String
//    let industry: String
//    let exchange: String
//    let ceo: String
//    let description: String
// }

class CompanyProfileController: FRGViewController {
    var companyName: String? {
        didSet {
            companyNameValue.text = companyName
        }
    }

    var symbol: String? {
        didSet {
            symbolValue.text = symbol
            guard let symbol = symbol else { return }
            guard let url = URL(string: "https://financialmodelingprep.com/api/v3/company/profile/\(symbol)?apikey=\(Constants.APIKey)") else { return }

            URLSession.shared.dataTask(with: url) { data, _, err in
                if let err = err {
                    if err._code == NSURLErrorTimedOut {
                        print("Time Out: \(err)")
                        return
                    } else if err._code == NSURLErrorCancelled {
                        print("Network Cancelled: \(err)")
                        return
                    }
                    print("Network Error: \(err)")
                    return
                }

                guard let data = data else { return }

                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers)
                    guard let level1 = json as? [String: Any] else { return }

                    guard let profileDict = level1["profile"] as? [String: Any] else { return }

                    DispatchQueue.main.async {
                        self.imageView.hideSkeleton()
                        self.websiteValue.hideSkeleton()
                        self.industryValue.hideSkeleton()
                        self.exchangeValue.hideSkeleton()
                        self.ceoValue.hideSkeleton()
                        self.descriptionValue.hideSkeleton()

                        let processor = DownsamplingImageProcessor(size: CGSize(width: 100, height: 100))
                        self.imageView.kf.indicatorType = .activity
                        self.imageView.kf.setImage(
                            with: URL(string: profileDict["image"] as? String ?? ""),
                            placeholder: UIImage(named: "select_photo_empty"),
                            options: [
                                .processor(processor),
                                .scaleFactor(UIScreen.main.scale),
                                .transition(.fade(0.6)),
                                .cacheOriginalImage,
                            ]
                        )
                        self.websiteValue.text = profileDict["website"] as? String
                        self.industryValue.text = profileDict["industry"] as? String
                        self.exchangeValue.text = profileDict["exchange"] as? String
                        self.ceoValue.text = profileDict["ceo"] as? String
                        self.descriptionValue.text = profileDict["description"] as? String
                    }

                    return
                } catch let jsonError {
                    print("Parse JSON error: \(jsonError)")
                    return
                }
            }.resume()
        }
    }

    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    let topInset = 8
    let rowHeight = 30

    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "select_photo_empty")
        imageView.contentMode = .scaleAspectFit
        imageView.isSkeletonable = true
        return imageView
    }()

    private lazy var companyNameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Company Name".localized
        return label
    }()

    private lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Company Symbol".localized
        return label
    }()

    private lazy var websiteLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Website".localized
        return label
    }()

    private lazy var industryLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Industry".localized
        return label
    }()

    private lazy var exchangeLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "Exchange".localized
        return label
    }()

    private lazy var ceoLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.text = "CEO".localized
        return label
    }()

    private lazy var companyNameValue: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()

    private lazy var symbolValue: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        return label
    }()

    private lazy var descriptionValue: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.isSkeletonable = true
        return label
    }()

    private lazy var websiteValue: UITextView = {
        let textView = UITextView()
        textView.textAlignment = .left
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.dataDetectorTypes = .all
        textView.textContainer.lineFragmentPadding = .zero
        textView.isSkeletonable = true
        return textView
    }()

    private lazy var industryValue: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.isSkeletonable = true
        label.numberOfLines = 0
        return label
    }()

    private lazy var exchangeValue: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.isSkeletonable = true
        return label
    }()

    private lazy var ceoValue: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .left
        label.isSkeletonable = true
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupCancelButton()
        setupView()
    }
}

// MARK: - private function

extension CompanyProfileController {
    private func setupView() {
        title = "Company Profile".localized
        view.backgroundColor = .financialStatementColor
        view.addSubview(scrollView)

        let shareButton = UIButton(type: .custom)
        shareButton.snp.makeConstraints { make in
            make.height.width.equalTo(21)
        }
        shareButton.setImage(UIImage(named: "share-square-solid"), for: .normal)
        shareButton.addTarget(self, action: #selector(shareCompanyProfile(_:)), for: .touchUpInside)

        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: shareButton)

        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        scrollView.addSubviews(imageView)
        imageView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }

        scrollView.addSubviews(companyNameLabel, companyNameValue)
        companyNameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(topInset + 8)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }
        companyNameValue.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(topInset + 8)
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.height.greaterThanOrEqualTo(rowHeight)
        }

        scrollView.addSubviews(symbolLabel, symbolValue)
        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(companyNameValue.snp.bottom).offset(topInset)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }
        symbolValue.snp.makeConstraints { make in
            make.top.equalTo(companyNameValue.snp.bottom).offset(topInset)
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.height.equalTo(rowHeight)
        }

        scrollView.addSubviews(websiteLabel, websiteValue)
        websiteLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom).offset(topInset)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }
        websiteValue.snp.makeConstraints { make in
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.centerY.equalTo(websiteLabel.snp.centerY)
            make.height.equalTo(rowHeight)
        }

        scrollView.addSubview(industryLabel)
        scrollView.addSubview(industryValue)

        industryValue.snp.makeConstraints { make in
            make.top.equalTo(websiteLabel.snp.bottom).offset(topInset)
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.height.greaterThanOrEqualTo(rowHeight)
        }
        industryLabel.snp.makeConstraints { make in
            make.centerY.equalTo(industryValue)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }

        scrollView.addSubview(exchangeLabel)
        scrollView.addSubview(exchangeValue)
        exchangeLabel.snp.makeConstraints { make in
            make.top.equalTo(industryValue.snp.bottom).offset(topInset)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }
        exchangeValue.snp.makeConstraints { make in
            make.centerY.equalTo(exchangeLabel)
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.height.equalTo(rowHeight)
        }

        scrollView.addSubview(ceoLabel)
        scrollView.addSubview(ceoValue)
        ceoLabel.snp.makeConstraints { make in
            make.top.equalTo(exchangeLabel.snp.bottom).offset(topInset)
            make.left.equalToSuperview().offset(dataRowLeftRightSpace)
            make.right.equalToSuperview().multipliedBy(0.4).offset(-8)
            make.height.equalTo(rowHeight)
        }
        ceoValue.snp.makeConstraints { make in
            make.centerY.equalTo(ceoLabel)
            make.left.equalTo(view.snp.right).multipliedBy(0.4).offset(8)
            make.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.height.equalTo(rowHeight)
        }

        scrollView.addSubview(descriptionValue)
        descriptionValue.snp.makeConstraints { make in
            make.top.equalTo(ceoLabel.snp.bottom).offset(topInset)
            make.width.equalTo(view).offset(-2 * dataRowLeftRightSpace)
            make.left.right.equalToSuperview().inset(dataRowLeftRightSpace)
            make.bottom.equalToSuperview().offset(-80)
        }

        #if !targetEnvironment(macCatalyst)
            if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
            } else {
                view.addSubview(bannerView)
                bannerView.snp.makeConstraints { make in
                    make.height.equalTo(50)
                    make.width.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                    make.centerX.equalToSuperview()
                }
            }
        #endif

        imageView.showAnimatedGradientSkeleton()
        websiteValue.showAnimatedGradientSkeleton()
        industryValue.showAnimatedGradientSkeleton()
        exchangeValue.showAnimatedGradientSkeleton()
        ceoValue.showAnimatedGradientSkeleton()
        descriptionValue.showAnimatedGradientSkeleton()
    }
}

// MARK: - actions

extension CompanyProfileController {
    @objc func shareCompanyProfile(_ sender: UIButton) {
        print("shareCompanyProfile")
        var str: String = ""

        str += "\("Company Name".localized):\t\(companyNameValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\("Company Symbol".localized):\t\(symbolValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\("Website".localized):\t\(websiteValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\("Industry".localized):\t\(industryValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\("Exchange".localized):\t\(exchangeValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\("CEO".localized):\t\(ceoValue.text ?? "No Data".localized)\n"

        str += "\n"

        str += "\(descriptionValue.text ?? "No Data".localized)\n"

        str += "\n"

        let file = getDocumentsDirectory().appendingPathComponent("\("Company Profile".localized) \(symbolValue.text ?? "No Data".localized).txt")

        do {
            try str.write(to: file, atomically: true, encoding: String.Encoding.utf8)
        } catch let err {
            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
            print("Error when create Company Profile.txt: \(err)")
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

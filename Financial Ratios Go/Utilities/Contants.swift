//
//  Contants.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/12/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

struct Constants {
    static let facebookPageID = "104357371640600"

    static let finanicalRatiosGoIOSAppID = "1481582303"
    static let finanicalRatiosGoMacOSAppID = "1486184864"
    static let financeGoAppID = "1519476344"
    static let countdownDaysAppID = "1525084657"
    static let moneyTrackerAppID = "1534244892"
    static let BMIDiaryAppID = "1521281509"
    static let novelsHubAppID = "1528820845"
    static let nasaLoverID = "1595232677"

    // This is a free account API key. Replace with your API key
    static let APIKey = "Sl3KekCBLRBGoFYGZO24KhiKTsTDg6ZA"

    #if DEBUG
        static let bannerViewAdUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let rewardAdUnitID = "ca-app-pub-3940256099942544/1712485313"
        static let interstitialAdID = "ca-app-pub-3940256099942544/1033173712"
        static let appOpenAdID = "ca-app-pub-3940256099942544/5662855259"
    #else
        // These are demo Ads ID. Replace with your Ads ID
        static let bannerViewAdUnitID = "ca-app-pub-3940256099942544/2934735716"
        static let rewardAdUnitID = "ca-app-pub-3940256099942544/1712485313"
        static let interstitialAdID = "ca-app-pub-3940256099942544/1033173712"
        static let appOpenAdID = "ca-app-pub-3940256099942544/5662855259"
    #endif
}

let versionNum: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""

let isIphone: Bool = UIDevice.current.userInterfaceIdiom != .pad

let sectionHeight: CGFloat = isIphone ? 42 : 54
let companyRowHeight: CGFloat = isIphone ? 72 : 88
let statementRowHeight: CGFloat = isIphone ? 40 : 52
let menuRowHeight: CGFloat = isIphone ? 56 : 72

let sectionTitleFont: UIFont = isIphone ? UIFont.systemFont(ofSize: 16, weight: .bold) : UIFont.systemFont(ofSize: 20, weight: .bold)
let dataRowTextFont: UIFont = isIphone ? UIFont.systemFont(ofSize: 15) : UIFont.systemFont(ofSize: 18)
let dataRowTextFontSize: CGFloat = isIphone ? 15 : 18
let markerSize = isIphone ? 15 : 18

let dataRowLeftRightSpace: CGFloat = isIphone ? 16 : 20

let Defaults = UserDefaults.standard

struct UserDefaultsKeys {
    static let CALCULATE_COUNT = "CALCULATE_COUNT"
    static let VERSION_215_CLEAR_CACHE = "VERSION_215_CLEAR_CACHE"
    struct AdsRequestInfo {
        static let timesToOpenInterstitialAds = "timesToOpenInterstitialAds"
    }
}

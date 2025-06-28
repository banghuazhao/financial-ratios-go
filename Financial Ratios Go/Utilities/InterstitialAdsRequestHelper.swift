//
//  InterstitialAdsRequestHelper.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 2021/1/13.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import Foundation

struct InterstitialAdsRequestHelper {
    static let requestThreshold = 2

    static func incrementRequestCount() {
        if var requestCount = UserDefaults.standard.value(forKey: UserDefaultsKeys.AdsRequestInfo.timesToOpenInterstitialAds) as? Int {
            requestCount += 1
            UserDefaults.standard.setValue(requestCount, forKey: UserDefaultsKeys.AdsRequestInfo.timesToOpenInterstitialAds)
            print("requestCount: \(requestCount)")
        } else {
            UserDefaults.standard.setValue(1, forKey: UserDefaultsKeys.AdsRequestInfo.timesToOpenInterstitialAds)
            print("requestCount is initialized: 1")
        }
    }

    static func checkLoadInterstitialAd() -> Bool {
        let requestCount = UserDefaults.standard.integer(forKey: UserDefaultsKeys.AdsRequestInfo.timesToOpenInterstitialAds)

        if requestCount >= requestThreshold {
            return true
        }
        return false
    }

    static func increaseRequestAndCheckLoadInterstitialAd() -> Bool {
        incrementRequestCount()
        let willLoadInterstitialAd = checkLoadInterstitialAd()
        return willLoadInterstitialAd
    }

    static func resetRequestCount() {
        UserDefaults.standard.setValue(0, forKey: UserDefaultsKeys.AdsRequestInfo.timesToOpenInterstitialAds)
        print("resetRequestCount")
    }
}

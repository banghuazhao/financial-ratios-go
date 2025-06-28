//
//  StoreReviewHelper.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 12/2/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation
import StoreKit

struct StoreReviewHelper {
    static func incrementCalculateCount() { // called from appdelegate didfinishLaunchingWithOptions:
        guard var calculateCount = Defaults.value(forKey: UserDefaultsKeys.CALCULATE_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.CALCULATE_COUNT)
            return
        }
        calculateCount += 1
        Defaults.set(calculateCount, forKey: UserDefaultsKeys.CALCULATE_COUNT)
    }

    static func checkAndAskForReview() { // call this whenever appropriate
        // this will not be shown everytime. Apple has some internal logic on how to show this.
        guard let calculateCount = Defaults.value(forKey: UserDefaultsKeys.CALCULATE_COUNT) as? Int else {
            Defaults.set(1, forKey: UserDefaultsKeys.CALCULATE_COUNT)
            return
        }

        switch calculateCount {
        case 5, 25:
            StoreReviewHelper().requestReview()
        case _ where calculateCount % 100 == 0:
            StoreReviewHelper().requestReview()
        default:
            print("Calculate count is : \(calculateCount)")
            break
        }
    }

    func requestReview() {
        SKStoreReviewController.requestReview()
    }
}

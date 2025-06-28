//
//  MenuModel.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/6/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class MenuModel {
    let name: String
    let image: UIImage

    init(name: String, image: UIImage) {
        self.name = name
        self.image = image
    }
}

class MenuModels {
    var models: [MenuModel]

    init() {
        let about = MenuModel(name: "About this App", image: UIImage(named: "info-circle-solid")!)

        let removeAds = MenuModel(name: "Remove Ads", image: UIImage(named: "icon_see")!)

        let language = MenuModel(name: "Change language", image: UIImage(named: "language-solid")!)

        let clearCache = MenuModel(name: "Clear Cache", image: UIImage(named: "trash-alt-solid")!)

        let feedback = MenuModel(name: "Feedback", image: UIImage(named: "comment-alt-regular")!)

        let rate = MenuModel(name: "Rate this App", image: UIImage(named: "star-solid")!)

        let share = MenuModel(name: "Share this App", image: UIImage(named: "share_app")!)

        let more = MenuModel(name: "More Apps", image: UIImage(named: "more")!)

        #if targetEnvironment(macCatalyst)
            models = [about, language, clearCache, feedback, rate, share, more]
        #else
            models = [about, removeAds, language, clearCache, feedback, rate, share, more]
        #endif
    }
}

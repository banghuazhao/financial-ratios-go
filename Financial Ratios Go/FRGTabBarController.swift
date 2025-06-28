//
//  FRGTabBarController.swift
//  FRG
//
//  Created by Banghua Zhao on 12/15/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

// all
var companies: [Company]? = [Company]()
var isSingle: Bool = true

// single
var company: Company = Company(symbol: "", name: "", logoImage: Data())
var fiscalPeriod: FiscalPeriod = FiscalPeriod(time: "", period: "")
var isHomeFetchOnlineData: Bool = true

// compare
var compareCompany: Company = Company(symbol: "", name: "", logoImage: Data())
var fiscalPeriod1: FiscalPeriod = FiscalPeriod(time: "", period: "")
var fiscalPeriod2: FiscalPeriod = FiscalPeriod(time: "", period: "")
var isCompareFetchOnlineData: Bool = true

class FRGTabBarController: UITabBarController {
    lazy var singleController: SingleController = {
        let singleController = SingleController()
        singleController.tabBarItem.title = "Financial Ratios".localized
        singleController.tabBarItem.image = #imageLiteral(resourceName: "single")
        singleController.tabBarItem.imageInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        if isIphone {
            singleController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: -30, vertical: 0)
        } else {
            if #available(iOS 13.0, *) {
                singleController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: -48, vertical: 0)
            }
        }
        return singleController
    }()

    lazy var compareController: CompareController = {
        let compareController = CompareController()
        compareController.tabBarItem.title = "Statement Compare".localized
        compareController.tabBarItem.image = #imageLiteral(resourceName: "compare")
        compareController.tabBarItem.imageInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        if isIphone {
            compareController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 30, vertical: 0)
        } else {
            if #available(iOS 13.0, *) {
                compareController.tabBarItem.titlePositionAdjustment = UIOffset(horizontal: 48, vertical: 0)
            }
        }
        return compareController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = .navBarColor
        tabBar.isTranslucent = false
        tabBar.tintColor = .headerViewColor
        tabBar.unselectedItemTintColor = .white
        setViewControllers([singleController, compareController], animated: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
}

// MARK: -  actions

extension FRGTabBarController {
}

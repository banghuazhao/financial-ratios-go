//
//  AppDelegate.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/22/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

import EFCountingLabel

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
    import IQKeyboardManager
#endif

var screenTapGesture: UITapGestureRecognizer!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate {
    #if !targetEnvironment(macCatalyst)
        var appOpenAd: GADAppOpenAd?
        var loadTime: Date = Date()
    #endif

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        #if !targetEnvironment(macCatalyst)
            GADMobileAds.sharedInstance().start(completionHandler: nil)
        #endif

        print(Locale.current.identifier)

        window = UIWindow(frame: UIScreen.main.bounds)

        setCompanyLists()

        if UserDefaults.standard.value(forKey: UserDefaultsKeys.VERSION_215_CLEAR_CACHE) as? Bool == nil {
            clearCacheOfLocal()
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.VERSION_215_CLEAR_CACHE)
        }

        let navigationController = FRGNavigationController(rootViewController: FRGTabBarController())

        window?.rootViewController = navigationController

        #if !targetEnvironment(macCatalyst)
            IQKeyboardManager.shared().isEnabled = true
        #endif

        screenTapGesture = UITapGestureRecognizer(target: self, action: nil)
        screenTapGesture.cancelsTouchesInView = false
        window?.addGestureRecognizer(screenTapGesture)

        window?.makeKeyAndVisible()

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        #if !targetEnvironment(macCatalyst)
            requestATTPermission()
            if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
            } else {
                tryToPresentAd()
            }
        #endif
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

extension AppDelegate {
    #if targetEnvironment(macCatalyst)
        override func buildMenu(with builder: UIMenuBuilder) {
            super.buildMenu(with: builder)
            builder.remove(menu: .help)
            builder.remove(menu: .format)
        }
    #endif
}

// MARK: - setCompanyLists

extension AppDelegate {
    private func setCompanyLists() {
        if let url = Bundle.main.url(forResource: "companyList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url, options: .alwaysMapped)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>, let symbolsList = jsonResult["symbolsList"] as? [[String: Any]] {
                    for symbolList in symbolsList {
                        let name = symbolList["name"] as! String
                        let symbol = symbolList["symbol"] as! String
                        companies?.append(Company(symbol: symbol, name: name, logoImage: Data()))
                    }
                }
            } catch let error {
                print(error)
            }
        }
        let companyLogo = UIImage(named: "MSFT.jpg")?.jpegData(compressionQuality: 1.0) ?? Data()
        company = Company(symbol: "MSFT", name: "Microsoft Corporation", logoImage: companyLogo)
        fiscalPeriod = FiscalPeriod(time: "2019-09-30", period: "Quarterly")

        compareCompany = Company(symbol: "MSFT", name: "Microsoft Corporation", logoImage: companyLogo)
        fiscalPeriod1 = FiscalPeriod(time: "2019-09-30", period: "Quarterly")
        fiscalPeriod2 = FiscalPeriod(time: "2019-06-30", period: "Quarterly")
    }
}

#if !targetEnvironment(macCatalyst)

    // MARK: - App open ad related

    extension AppDelegate: GADFullScreenContentDelegate {
        func requestAppOpenAd() {
            appOpenAd = nil
            GADAppOpenAd.load(
                withAdUnitID: Constants.appOpenAdID,
                request: GADRequest(),
                orientation: .portrait) { appOpenAd, error in
                if error != nil {
                    print("Failed to load app open ad: \(String(describing: error))")
                }
                self.appOpenAd = appOpenAd
                self.appOpenAd?.fullScreenContentDelegate = self
                self.loadTime = Date()
            }
        }

        func tryToPresentAd() {
            let ad = appOpenAd
            appOpenAd = nil
            if ad != nil && wasLoadTimeLessThanNHoursAgo(n: 4) {
                if let rootViewController = window?.rootViewController {
                    ad?.present(fromRootViewController: rootViewController)
                }
            } else {
                requestAppOpenAd()
            }
        }

        func wasLoadTimeLessThanNHoursAgo(n: Int) -> Bool {
            let now = Date()
            let timeIntervalBetweenNowAndLoadTime = now.timeIntervalSince(loadTime)
            let secondsPerHour = 3600.0
            let intervalInHours = timeIntervalBetweenNowAndLoadTime / secondsPerHour
            return intervalInHours < Double(n)
        }

        func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
            print("didFailToPresentFullSCreenCContentWithError")
            requestAppOpenAd()
        }
        
        func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
            print("adDidDismissFullScreenContent")
            requestAppOpenAd()
        }
    }
#endif

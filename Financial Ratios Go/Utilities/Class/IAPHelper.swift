//
//  IAPManager.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 2021/2/10.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import StoreKit

public struct RemoveAdsProduct {
    // **Note**: The `removeAdsProductIdentifier` ("com.BanghuaZhao.FinancialRatiosGo.RemoveAdsForever") is specific to this app’s App Store Connect configuration. If you fork this project, create your own In-App Purchase product in App Store Connect and update the identifier accordingly.
    static let removeAdsProductIdentifier = "com.BanghuaZhao.FinancialRatiosGo.RemoveAdsForever"

    private static let productIdentifiers: Set<ProductIdentifier> = [RemoveAdsProduct.removeAdsProductIdentifier]

    static let store = IAPHelper(productIds: RemoveAdsProduct.productIdentifiers)
}

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void

extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
    static let IAPHelperRestoreNotification = Notification.Name("IAPHelperRestoreNotification")
    static let IAPHelperPurchaseDoneNotification = Notification.Name("IAPHelperPurchaseDoneNotification")
    static let IAPHelperPurchaseFailNotification = Notification.Name("IAPHelperPurchaseFailNotification")
    static let IAPHelperRestoreFailNotification = Notification.Name("IAPHelperRestoreFailNotification")
}

class IAPHelper: NSObject {
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers: Set<ProductIdentifier> = []
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()

        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension IAPHelper {
    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct) {
        print("Buying \(product.productIdentifier)...")
        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
        return purchasedProductIdentifiers.contains(productIdentifier)
    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()

        for p in products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("Failed to load list of products.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        if queue.transactions.count == 0 {
            NotificationCenter.default.post(name: .IAPHelperRestoreFailNotification, object: nil)
            print("Nothing to restore...")
        } else {
            print("Restored...")
        }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            print("transaction.transactionState: \(transaction.transactionState.rawValue)")
            switch transaction.transactionState {
            case .purchased:
                complete(transaction: transaction)
                break
            case .failed:
                fail(transaction: transaction)
                break
            case .restored:
                restore(transaction: transaction)
                break
            case .deferred:
                print("deferred...")
                break
            case .purchasing:
                print("purchasing...")
                break
            @unknown default:
                fatalError()
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {
        let identifier = transaction.payment.productIdentifier
        print("complete... \(identifier)")
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseDoneNotification, object: identifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        print("restore... \(productIdentifier)")
        let identifier = transaction.payment.productIdentifier
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
        NotificationCenter.default.post(name: .IAPHelperRestoreNotification, object: identifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
           let localizedDescription = transaction.error?.localizedDescription,
           transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }
        NotificationCenter.default.post(name: .IAPHelperPurchaseFailNotification, object: nil)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
}

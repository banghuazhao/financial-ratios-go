//
//  Others.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/12/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

func convertStringToCurrency(amount: String) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.currencySymbol = ""
    numberFormatter.locale = Locale.current
    if let amountNum = Double(amount) {
        return numberFormatter.string(from: NSNumber(value: amountNum))!
    } else {
        return amount
    }
}

func convertCurrencyToDouble(input: String) -> Double? {
    let numberFormatter = NumberFormatter()
    numberFormatter.numberStyle = .currency
    numberFormatter.locale = Locale.current
    numberFormatter.currencySymbol = ""
    return numberFormatter.number(from: input)?.doubleValue
}

func hideHeaderIndictors(headerViews: [FRGHeaderView]) {
    for headerView in headerViews {
        headerView.loadingSpinner.stopAnimating()
        headerView.loadingSpinner.isHidden = true
        headerView.loadingLabel.isHidden = true
        headerView.correctMarker.isHidden = true
        headerView.correctLabel.isHidden = true
        headerView.wrongMarker.isHidden = true
        headerView.wrongLabel.isHidden = true
    }
}

func showLoading(headerViews: [FRGHeaderView]) {
    for headView in headerViews {
        if !headView.isStatic {
            headView.loadingSpinner.startAnimating()
            headView.loadingSpinner.isHidden = false
            headView.loadingLabel.isHidden = false
            headView.correctMarker.isHidden = true
            headView.correctLabel.isHidden = true
            headView.wrongMarker.isHidden = true
            headView.wrongLabel.isHidden = true
        }
    }
}

func showSuccess(headerViews: [FRGHeaderView]) {
    for headerView in headerViews {
        if !headerView.isStatic {
            headerView.loadingSpinner.stopAnimating()
            headerView.loadingSpinner.isHidden = true
            headerView.loadingLabel.isHidden = true
            headerView.correctMarker.isHidden = false
            headerView.correctLabel.isHidden = false
            headerView.wrongMarker.isHidden = true
            headerView.wrongLabel.isHidden = true
        }
    }
}

func showError(headerViews: [FRGHeaderView], errorDiscription: String) {
    for headerView in headerViews {
        if !headerView.isStatic {
            headerView.loadingSpinner.stopAnimating()
            headerView.loadingSpinner.isHidden = true
            headerView.loadingLabel.isHidden = true
            headerView.correctMarker.isHidden = true
            headerView.correctLabel.isHidden = true
            headerView.wrongMarker.isHidden = false
            headerView.wrongLabel.isHidden = false
            headerView.wrongLabel.text = errorDiscription
        }
    }
}

func calculateTextViewHeigh(by text: String, textViewWidth: CGFloat) -> CGFloat {
    let dummy = UITextView()
    dummy.font = dataRowTextFont
    dummy.text = text
    dummy.isEditable = false
    let sizeThatFits = dummy.sizeThatFits(CGSize(width: textViewWidth, height: CGFloat.greatestFiniteMagnitude))
    return sizeThatFits.height + 80
}

extension UIApplication {
    class func getTopMostViewController() -> UIViewController? {
        let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first
        if var topController = keyWindow?.rootViewController {
            while let presentedViewController = topController.presentedViewController {
                topController = presentedViewController
            }
            return topController
        } else {
            return nil
        }
    }
}

//
//  FinancialRatioModel.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/22/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

struct FinancialRatio {
    static let liquidityMeasurementRatiosLabel = [
        "Current Ratio",
        "Cash Ratio",
        "Acid-Test Ratio"]
    static var liquidityMeasurementRatiosValues = [
        "Current Ratio": "",
        "Cash Ratio": "",
        "Acid-Test Ratio": ""]

    static let debtRatiosLabel = [
        "Debt Ratio",
        "Interest Coverage",
        "Cash Flow to Debt Ratio",
        "Debt to Equity Ratio",
        "Equity Ratio"]
    static var debtRatiosValues = [
        "Debt Ratio": "",
        "Interest Coverage": "",
        "Cash Flow to Debt Ratio": "",
        "Debt to Equity Ratio": "",
        "Equity Ratio": ""]

    static let profitabilityIndicatorRatiosLabel = [
        "Operating Profit Margin",
        "Net Profit Margin",
        "Return on Equity",
        "Return on Debt",
        "Return on Invested Capital",
        "Return on Capital Employed"]
    static var profitabilityIndicatorRatiosValues = [
        "Operating Profit Margin": "",
        "Net Profit Margin": "",
        "Return on Equity": "",
        "Return on Debt": "",
        "Return on Invested Capital": "",
        "Return on Capital Employed": ""]

    static let cashFlowIndicatorRatiosLabel = [
        "CFROI",
        "Dividend Payout Ratio",
        "Free Cash Flow-To-Sales",
        "Retention Ratio"]
    static var cashFlowIndicatorRatiosValues = [
        "CFROI": "",
        "Dividend Payout Ratio": "",
        "Free Cash Flow-To-Sales": "",
        "Retention Ratio": ""]

    static func initializeFinancialRatio() {
        liquidityMeasurementRatiosValues = FinancialRatio.liquidityMeasurementRatiosValues
        debtRatiosValues = FinancialRatio.debtRatiosValues
        profitabilityIndicatorRatiosValues = FinancialRatio.profitabilityIndicatorRatiosValues
        cashFlowIndicatorRatiosValues = FinancialRatio.cashFlowIndicatorRatiosValues
    }
}

let liquidityMeasurementRatiosLabel = FinancialRatio.liquidityMeasurementRatiosLabel
var liquidityMeasurementRatiosValues = FinancialRatio.liquidityMeasurementRatiosValues
var liquidityMeasurementRatiosValues1 = FinancialRatio.liquidityMeasurementRatiosValues
var liquidityMeasurementRatiosValues2 = FinancialRatio.liquidityMeasurementRatiosValues

let debtRatiosLabel = FinancialRatio.debtRatiosLabel
var debtRatiosValues = FinancialRatio.debtRatiosValues
var debtRatiosValues1 = FinancialRatio.debtRatiosValues
var debtRatiosValues2 = FinancialRatio.debtRatiosValues

let profitabilityIndicatorRatiosLabel = FinancialRatio.profitabilityIndicatorRatiosLabel
var profitabilityIndicatorRatiosValues = FinancialRatio.profitabilityIndicatorRatiosValues
var profitabilityIndicatorRatiosValues1 = FinancialRatio.profitabilityIndicatorRatiosValues
var profitabilityIndicatorRatiosValues2 = FinancialRatio.profitabilityIndicatorRatiosValues

let cashFlowIndicatorRatiosLabel = FinancialRatio.cashFlowIndicatorRatiosLabel
var cashFlowIndicatorRatiosValues = FinancialRatio.cashFlowIndicatorRatiosValues
var cashFlowIndicatorRatiosValues1 = FinancialRatio.cashFlowIndicatorRatiosValues
var cashFlowIndicatorRatiosValues2 = FinancialRatio.cashFlowIndicatorRatiosValues

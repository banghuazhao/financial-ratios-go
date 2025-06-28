//
//  FinancialStatement.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/21/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

struct FinancialStatement {
    static let incomeStatementLabels = [
        "Revenue",
        "Operating Income",
        "EBIT",
        "Interest Expense",
        "Income Tax Expense",
        "Net Income"]

    static let incomeStatementAPI = [
        "revenue",
        "operatingIncome",
        "ebitda",
        "interestExpense",
        "incomeTaxExpense",
        "netIncome"]

    static let incomeStatementLabelsMapping = [
        "Revenue": "revenue",
        "Operating Income": "operatingIncome",
        "EBIT": "ebitda",
        "Interest Expense": "interestExpense",
        "Income Tax Expense": "incomeTaxExpense",
        "Net Income": "netIncome"]

    static var incomeStatementValues: [String: String] = [
        "revenue": "",
        "operatingIncome": "",
        "ebitda": "",
        "interestExpense": "",
        "incomeTaxExpense": "",
        "netIncome": ""]

    static let balanceSheetStatementLabels = [
        "Cash and Cash Equivalents",
        "Short-term Investments",
        "Receivables",
        "Total Current Assets",
        "Total Assets",
        "Short-term Debt",
        "Long-term Debt",
        "Total Current Liabilities",
        "Total Liabilities",
        "Total Shareholders Equity"]

    static let balanceSheetStatementAPI = [
        "cashAndCashEquivalents",
        "shortTermInvestments",
        "netReceivables",
        "totalCurrentAssets",
        "totalAssets",
        "shortTermDebt",
        "longTermDebt",
        "totalCurrentLiabilities",
        "totalLiabilities",
        "totalStockholdersEquity"]

    static let balanceSheetStatementLabelsMapping: [String: String] = [
        "Cash and Cash Equivalents": "cashAndCashEquivalents",
        "Short-term Investments": "shortTermInvestments",
        "Receivables": "netReceivables",
        "Total Current Assets": "totalCurrentAssets",
        "Total Assets": "totalAssets",
        "Short-term Debt": "shortTermDebt",
        "Long-term Debt": "longTermDebt",
        "Total Current Liabilities": "totalCurrentLiabilities",
        "Total Liabilities": "totalLiabilities",
        "Total Shareholders Equity": "totalStockholdersEquity"]

    static var balanceSheetStatementValues: [String: String] = [
        "cashAndCashEquivalents": "",
        "shortTermInvestments": "",
        "netReceivables": "",
        "totalCurrentAssets": "",
        "totalAssets": "",
        "shortTermDebt": "",
        "longTermDebt": "",
        "totalCurrentLiabilities": "",
        "totalLiabilities": "",
        "totalStockholdersEquity": ""]

    static let cashFlowStatementLabels = [
        "Operating Cash Flow",
        "Dividend Payments",
        "Free Cash Flow"]

    static let cashFlowStatementAPI = [
        "operatingCashFlow",
        "dividendsPaid",
        "freeCashFlow"]

    static let cashFlowStatementLabelsMapping: [String: String] = [
        "Operating Cash Flow": "operatingCashFlow",
        "Dividend Payments": "dividendsPaid",
        "Free Cash Flow": "freeCashFlow"]

    static var cashFlowStatementValues: [String: String] = [
        "operatingCashFlow": "",
        "dividendsPaid": "",
        "freeCashFlow": ""]

    static func initializeFinancialStatement() {
        incomeStatementValues = FinancialStatement.incomeStatementValues
        balanceSheetStatementValues = FinancialStatement.balanceSheetStatementValues
        cashFlowStatementValues = FinancialStatement.cashFlowStatementValues
    }

    static var incomeStatementValues1: [String: String] = [
        "revenue": "",
        "operatingIncome": "",
        "ebitda": "",
        "interestExpense": "",
        "incomeTaxExpense": "",
        "netIncome": ""]

    static var balanceSheetStatementValues1: [String: String] = [
        "cashAndCashEquivalents": "",
        "shortTermInvestments": "",
        "netReceivables": "",
        "totalCurrentAssets": "",
        "totalAssets": "",
        "shortTermDebt": "",
        "longTermDebt": "",
        "totalCurrentLiabilities": "",
        "totalLiabilities": "",
        "totalStockholdersEquity": ""]

    static var cashFlowStatementValues1: [String: String] = [
        "operatingCashFlow": "",
        "dividendsPaid": "",
        "freeCashFlow": ""]

    static var incomeStatementValues2: [String: String] = [
        "revenue": "",
        "operatingIncome": "",
        "ebitda": "",
        "interestExpense": "",
        "incomeTaxExpense": "",
        "netIncome": ""]

    static var balanceSheetStatementValues2: [String: String] = [
        "cashAndCashEquivalents": "",
        "shortTermInvestments": "",
        "netReceivables": "",
        "totalCurrentAssets": "",
        "totalAssets": "",
        "shortTermDebt": "",
        "longTermDebt": "",
        "totalCurrentLiabilities": "",
        "totalLiabilities": "",
        "totalStockholdersEquity": ""]

    static var cashFlowStatementValues2: [String: String] = [
        "operatingCashFlow": "",
        "dividendsPaid": "",
        "freeCashFlow": ""]

    static func initializeFinancialStatementCompare() {
        // 1
        incomeStatementValues1 = FinancialStatement.incomeStatementValues1
        balanceSheetStatementValues1 = FinancialStatement.balanceSheetStatementValues1
        cashFlowStatementValues1 = FinancialStatement.cashFlowStatementValues1

        // 2
        incomeStatementValues2 = FinancialStatement.incomeStatementValues2
        balanceSheetStatementValues2 = FinancialStatement.balanceSheetStatementValues2
        cashFlowStatementValues2 = FinancialStatement.cashFlowStatementValues2
    }

    static var incomeStatementValuesCompare1: [String: String] = [
        "revenue": "",
        "operatingIncome": "",
        "ebitda": "",
        "interestExpense": "",
        "incomeTaxExpense": "",
        "netIncome": ""]

    static var balanceSheetStatementValuesCompare1: [String: String] = [
        "cashAndCashEquivalents": "",
        "shortTermInvestments": "",
        "netReceivables": "",
        "totalCurrentAssets": "",
        "totalAssets": "",
        "shortTermDebt": "",
        "longTermDebt": "",
        "totalCurrentLiabilities": "",
        "totalLiabilities": "",
        "totalStockholdersEquity": ""]

    static var cashFlowStatementValuesCompare1: [String: String] = [
        "operatingCashFlow": "",
        "dividendsPaid": "",
        "freeCashFlow": ""]

    static var incomeStatementValuesCompare2: [String: String] = [
        "revenue": "",
        "operatingIncome": "",
        "ebitda": "",
        "interestExpense": "",
        "incomeTaxExpense": "",
        "netIncome": ""]

    static var balanceSheetStatementValuesCompare2: [String: String] = [
        "cashAndCashEquivalents": "",
        "shortTermInvestments": "",
        "netReceivables": "",
        "totalCurrentAssets": "",
        "totalAssets": "",
        "shortTermDebt": "",
        "longTermDebt": "",
        "totalCurrentLiabilities": "",
        "totalLiabilities": "",
        "totalStockholdersEquity": ""]

    static var cashFlowStatementValuesCompare2: [String: String] = [
        "operatingCashFlow": "",
        "dividendsPaid": "",
        "freeCashFlow": ""]

    static func initializeFinancialStatementCompareResult() {
        // 1
        incomeStatementValuesCompare1 = FinancialStatement.incomeStatementValuesCompare1
        balanceSheetStatementValuesCompare1 = FinancialStatement.balanceSheetStatementValuesCompare1
        cashFlowStatementValuesCompare1 = FinancialStatement.cashFlowStatementValuesCompare1

        // 2
        incomeStatementValuesCompare2 = FinancialStatement.incomeStatementValuesCompare2
        balanceSheetStatementValuesCompare2 = FinancialStatement.balanceSheetStatementValuesCompare2
        cashFlowStatementValuesCompare2 = FinancialStatement.cashFlowStatementValuesCompare2
    }
}

let incomeStatementLabels = FinancialStatement.incomeStatementLabels
let incomeStatementAPI = FinancialStatement.incomeStatementAPI
let incomeStatementLabelsMapping = FinancialStatement.incomeStatementLabelsMapping
var incomeStatementValues: [String: String] = FinancialStatement.incomeStatementValues
var incomeStatementValues1: [String: String] = FinancialStatement.incomeStatementValues1
var incomeStatementValues2: [String: String] = FinancialStatement.incomeStatementValues2
var incomeStatementValuesCompare1: [String: String] = FinancialStatement.incomeStatementValuesCompare1
var incomeStatementValuesCompare2: [String: String] = FinancialStatement.incomeStatementValuesCompare2

let balanceSheetStatementLabels = FinancialStatement.balanceSheetStatementLabels
let balanceSheetStatementAPI = FinancialStatement.balanceSheetStatementAPI
let balanceSheetStatementLabelsMapping: [String: String] = FinancialStatement.balanceSheetStatementLabelsMapping
var balanceSheetStatementValues: [String: String] = FinancialStatement.balanceSheetStatementValues
var balanceSheetStatementValues1: [String: String] = FinancialStatement.balanceSheetStatementValues1
var balanceSheetStatementValues2: [String: String] = FinancialStatement.balanceSheetStatementValues2
var balanceSheetStatementValuesCompare1: [String: String] = FinancialStatement.balanceSheetStatementValuesCompare1
var balanceSheetStatementValuesCompare2: [String: String] = FinancialStatement.balanceSheetStatementValuesCompare2

let cashFlowStatementLabels = FinancialStatement.cashFlowStatementLabels
let cashFlowStatementAPI = FinancialStatement.cashFlowStatementAPI
let cashFlowStatementLabelsMapping: [String: String] = FinancialStatement.cashFlowStatementLabelsMapping
var cashFlowStatementValues: [String: String] = FinancialStatement.cashFlowStatementValues
var cashFlowStatementValues1: [String: String] = FinancialStatement.cashFlowStatementValues1
var cashFlowStatementValues2: [String: String] = FinancialStatement.cashFlowStatementValues2
var cashFlowStatementValuesCompare1: [String: String] = FinancialStatement.cashFlowStatementValuesCompare1
var cashFlowStatementValuesCompare2: [String: String] = FinancialStatement.cashFlowStatementValuesCompare2

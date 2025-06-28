//
//  sectionHeaderModel.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/13/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

struct SectionHeader {
    var title: String
    var isStatic: Bool
}

let homeSectionHeaders: [SectionHeader] = [
    SectionHeader(title: "Company and Fiscal Period", isStatic: true),
    SectionHeader(title: "Income Statement", isStatic: false),
    SectionHeader(title: "Balance Sheet Statement", isStatic: false),
    SectionHeader(title: "Cash Flow Statement", isStatic: false)
]

let createCompanySectionHeaders: [SectionHeader] = [
    SectionHeader(title: "Dummy Header", isStatic: true),
    SectionHeader(title: "Income Statement", isStatic: true),
    SectionHeader(title: "Balance Sheet Statement", isStatic: true),
    SectionHeader(title: "Cash Flow Statement", isStatic: true)
]

let fiscalPeriodSectionHeaders: [SectionHeader] = [
    SectionHeader(title: "Annually", isStatic: false),
    SectionHeader(title: "Quarterly", isStatic: false),
]

let resultSectionHeaders: [SectionHeader] = [
    SectionHeader(title: "Company and Fiscal Period", isStatic: true),
    SectionHeader(title: "Liquidity Measurement Ratios", isStatic: true),
    SectionHeader(title: "Debt Ratios", isStatic: true),
    SectionHeader(title: "Profit Ability Indicator Ratios", isStatic: true),
    SectionHeader(title: "Cash Flow Indicator Ratios", isStatic: true),
    SectionHeader(title: "Other Ratios", isStatic: true),
]



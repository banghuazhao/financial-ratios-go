//
//  FiscalPeriod.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/18/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

class FiscalPeriod: NSObject, NSSecureCoding {
    static var supportsSecureCoding: Bool = true

    func encode(with coder: NSCoder) {
        coder.encode(time, forKey: "Time")
        coder.encode(period, forKey: "period")
    }

    required init?(coder: NSCoder) {
        time = coder.decodeObject(forKey: "Time") as! String
        period = coder.decodeObject(forKey: "period") as! String
    }

    var time: String
    var period: String

    init(time: String, period: String) {
        self.time = time
        self.period = period
    }
}

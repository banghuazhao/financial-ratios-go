//
//  String+Extension.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 2021/10/2.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import Foundation

extension String {
    func indexOfSubstring(subString: String) -> Int? {
        if let range: Range<String.Index> = self.range(of: subString) {
            let index: Int = distance(from: startIndex, to: range.lowerBound)
            return index
        } else {
            // substring not found
            return nil
        }
    }
}

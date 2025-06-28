//
//  Company.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/18/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import Foundation

struct Company: Decodable {
    var symbol: String
    var name: String
    var logoImage: Data

    enum DecodingError: Error {
        case missingFile
    }
}

extension Array where Element == Company {
    init(fileName: String) throws {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw Company.DecodingError.missingFile
        }

        let decoder = JSONDecoder()
        let data = try Data(contentsOf: url)
        self = try decoder.decode([Company].self, from: data)
    }
}

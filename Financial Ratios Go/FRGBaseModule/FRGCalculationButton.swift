//
//  FRGCalculationButton.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 11/16/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class FRGCalculationButton: UIButton {
    
    init() {
        super.init(frame: .zero)
        
        let buttonWidth = isIphone ? 140 : 200
        self.snp.makeConstraints { (make) in
            make.width.equalTo(buttonWidth)
            make.height.equalTo(38)
        }
        self.setTitle("Calculate".localized, for: .normal)
        self.setTitleColor(UIColor.navBarColor, for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        self.layer.cornerRadius = self.intrinsicContentSize.height / 2.0
        self.backgroundColor = .white
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

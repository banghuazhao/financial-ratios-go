//
//  FiscalPeriodCel.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/18/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class FiscalPeriodCell: UITableViewCell {

    let timeLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)
        
        self.backgroundColor = .financialStatementColor
        
        contentView.addSubview(timeLabel)
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.right.equalToSuperview().inset(dataRowLeftRightSpace)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

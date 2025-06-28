//
//  FinancialStatementTitleCell.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/21/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SnapKit
import UIKit

class FinancialStatementTitleCell: UITableViewCell {
    var financialTitleLabel: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    var financialPeriod1: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    var financialPeriod2: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .financialStatementColor

        contentView.addSubview(financialTitleLabel)
        contentView.addSubview(financialPeriod1)
        contentView.addSubview(financialPeriod2)


        financialTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        financialPeriod1.snp.makeConstraints { make in
            make.left.equalTo(financialTitleLabel.snp.right).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)
        }
        
        financialPeriod2.snp.makeConstraints { make in
            make.left.equalTo(financialPeriod1.snp.right).offset(dataRowLeftRightSpace - 4)
            make.right.equalTo(contentView).inset(dataRowLeftRightSpace - 4)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

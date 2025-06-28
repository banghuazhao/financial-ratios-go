//
//  FinancialStatementCompareCell.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/21/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SnapKit
import UIKit

class FinancialStatementCompareCell: UITableViewCell {
    var financialDataLabel: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    var financialDataTextField1: UITextField = {
        let textField = UITextField()
        textField.font = dataRowTextFont
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 8
        textField.textColor = .black
        textField.keyboardType = .numbersAndPunctuation
        return textField
    }()
    
    var financialDataTextField2: UITextField = {
        let textField = UITextField()
        textField.font = dataRowTextFont
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 8
        textField.textColor = .black
        textField.keyboardType = .numbersAndPunctuation
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .financialStatementColor

        contentView.addSubview(financialDataLabel)
        contentView.addSubview(financialDataTextField1)
        contentView.addSubview(financialDataTextField2)


        financialDataLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        financialDataTextField1.snp.makeConstraints { make in
            make.left.equalTo(financialDataLabel.snp.right).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)
        }
        
        financialDataTextField2.snp.makeConstraints { make in
            make.left.equalTo(financialDataTextField1.snp.right).offset(dataRowLeftRightSpace - 4)
            make.right.equalTo(contentView).inset(dataRowLeftRightSpace - 4)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)

        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

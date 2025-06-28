//
//  FinancialStatementCell.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/21/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SnapKit
import UIKit

class FinancialStatementCell: UITableViewCell {
    var financialDataLabel: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    var financialDataTextField: UITextField = {
        let textField = UITextField()
        textField.font = dataRowTextFont
        textField.adjustsFontSizeToFitWidth = true
        textField.minimumFontSize = 10
        textField.textColor = .black
        textField.keyboardType = .numbersAndPunctuation
        return textField
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        accessoryType = .detailButton
        backgroundColor = .financialStatementColor

        contentView.addSubview(financialDataLabel)
        contentView.addSubview(financialDataTextField)

        financialDataLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.5)
        }

        financialDataTextField.snp.makeConstraints { make in
            make.left.equalTo(financialDataLabel.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

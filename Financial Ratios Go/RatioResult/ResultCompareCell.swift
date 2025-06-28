//
//  ResultCompareCell.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/24/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import EFCountingLabel
import UIKit

class ResultCompareCell: UITableViewCell {
    lazy var resultDataLabel: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    lazy var resultDataValue1: EFCountingLabel = {
        let label = EFCountingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    lazy var resultDataValue2: EFCountingLabel = {
        let label = EFCountingLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .financialStatementColor
        separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)

        contentView.addSubview(resultDataLabel)
        contentView.addSubview(resultDataValue1)
        contentView.addSubview(resultDataValue2)

        resultDataLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        resultDataValue1.snp.makeConstraints { make in
            make.left.equalTo(resultDataLabel.snp.right).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)
        }

        resultDataValue2.snp.makeConstraints { make in
            make.left.equalTo(resultDataValue1.snp.right).offset(dataRowLeftRightSpace - 4)
            make.right.equalTo(contentView).inset(dataRowLeftRightSpace - 4)
            make.centerY.equalTo(contentView)
            make.width.equalToSuperview().multipliedBy(0.28)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

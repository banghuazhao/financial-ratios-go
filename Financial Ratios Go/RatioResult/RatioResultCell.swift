//
//  RatioResultCell.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/24/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import EFCountingLabel
import UIKit

class RatioResultCell: UITableViewCell {
    lazy var resultDataLabel: UILabel = {
        let label = UILabel()
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    lazy var resultDataValue: EFCountingLabel = {
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
        accessoryType = .detailButton
        separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)

        contentView.addSubview(resultDataLabel)
        contentView.addSubview(resultDataValue)

        resultDataLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
            make.width.equalTo(contentView).multipliedBy(0.5)
        }

        resultDataValue.snp.makeConstraints { make in
            make.left.equalTo(resultDataLabel.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

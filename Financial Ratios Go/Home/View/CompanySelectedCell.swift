//
//  CompanySelectedCell.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/18/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class CompanySelectedCell: UITableViewCell {
    let companyIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .financialStatementColor
        return imageView
    }()

    let companyNameAndCodeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        return label
    }()

    let financialTime: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .companyCellColor

        contentView.addSubviews(companyIconView, companyNameAndCodeLabel, financialTime)

        companyIconView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.width.equalTo(companyRowHeight - 16)
            make.height.equalTo(companyRowHeight - 16)
            make.centerY.equalTo(contentView)
        }

        companyNameAndCodeLabel.snp.makeConstraints { make in
            make.left.equalTo(companyIconView.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView).offset(-0.2 * companyRowHeight)
        }

        financialTime.snp.makeConstraints { make in
            make.left.equalTo(companyIconView.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView).offset(0.2 * companyRowHeight)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

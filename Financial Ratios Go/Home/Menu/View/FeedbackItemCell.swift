//
//  FeedbackItemCell.swift
//  Apps Bay
//
//  Created by Banghua Zhao on 1/1/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

class FeedbackItemCell: UITableViewCell {
    var feedbackItem: FeedbackItem? {
        didSet {
            guard let feedbackItem = feedbackItem else { return }
            iconView.image = feedbackItem.icon?.withRenderingMode(.alwaysTemplate)
            titleLabel.text = feedbackItem.title
            detailLabel.text = feedbackItem.detail
        }
    }

    lazy var iconView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.tintColor = UIColor(displayP3Red: 165/255, green: 172/255, blue: 179/255, alpha: 1.0)
    }

    lazy var titleLabel = UILabel().then { label in
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.font = UIFont.title
        label.textColor = UIColor.black
    }

    lazy var detailLabel = UILabel().then { label in
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.systemGray
        label.font = UIFont.normal
        label.textColor = UIColor.greyFontColor
    }

    lazy var rightArrowImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.greyFontColor
        imageView.image = UIImage(named: "button_rightArrow")?.withRenderingMode(.alwaysTemplate)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(rightArrowImageView)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(30)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(16)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalTo(rightArrowImageView.snp.left).offset(-12)
        }

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.bottom.equalToSuperview().offset(-16)
            make.left.equalTo(iconView.snp.right).offset(12)
            make.right.equalTo(rightArrowImageView.snp.left).offset(-12)
        }

        rightArrowImageView.snp.makeConstraints { make in
            make.width.equalTo(12)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

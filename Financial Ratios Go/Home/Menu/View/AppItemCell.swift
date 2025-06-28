//
//  AppItemCell.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 1/2/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

class AppItemCell: UITableViewCell {
    var appItem: AppItem? {
        didSet {
            guard let appItem = appItem else { return }
            iconView.image = appItem.icon
            titleLabel.text = appItem.title
            detailLabel.text = appItem.detail
        }
    }

    lazy var iconView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        imageView.layer.cornerRadius = 9
        imageView.layer.masksToBounds = true
        return imageView
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 17)
        return label
    }()

    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.textColor = UIColor.greyFontColor
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(iconView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        iconView.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.size.equalTo(50)
            make.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(16)
            make.right.equalToSuperview().inset(20)
        }

        detailLabel.snp.makeConstraints { make in
            make.bottom.equalTo(iconView)
            make.left.equalTo(iconView.snp.right).offset(16)
            make.right.equalToSuperview().inset(20)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

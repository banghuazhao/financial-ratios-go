//
//  RemoveAdsAboutCell.swift
//  Top Rankings
//
//  Created by Banghua Zhao on 2021/2/10.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import StoreKit
import UIKit

class RemoveAdsAboutCell: UITableViewCell {
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .greyFont2Color
        label.textAlignment = .center
        return label
    }()

    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .greyFont2Color
        label.textAlignment = .left
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(titleLabel)
        contentView.addSubview(detailLabel)

        titleLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview().inset(20)
        }

        titleLabel.text = "Purchase Notes".localized

        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().offset(-20)
        }

        detailLabel.text = """
        •\("After purchase, all of the Ads will be removed immediately.".localized)
        •\("The purchase is valid across different devices (iPhone and iPad) for the same Apple ID.".localized)
        •\("If users change a device or reinstall this App, restore purchase will store your previous purchase.".localized)
        """
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

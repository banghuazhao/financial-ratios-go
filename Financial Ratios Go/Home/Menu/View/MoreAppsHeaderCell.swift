//
//  MoreAppsHeaderCell.swift
//  Countdown Days
//
//  Created by Banghua Zhao on 2021/1/24.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

class MoreAppsHeaderCell: UITableViewHeaderFooterView {
    lazy var label = UILabel().then { label in
        label.text = "All the Apps are available in both Mac and iOS App Store".localized
        label.font = UIFont.title
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
    }

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        tintColor = .clear
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(20)
            make.bottom.equalToSuperview().inset(16)
            make.top.equalToSuperview().inset(30)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

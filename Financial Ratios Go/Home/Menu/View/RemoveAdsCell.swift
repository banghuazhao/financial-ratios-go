//
//  RemoveAdsCell.swift
//  Top Rankings
//
//  Created by Banghua Zhao on 2021/2/10.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import StoreKit
import UIKit

class RemoveAdsCell: UITableViewCell {
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency
        return formatter
    }()

    var product: SKProduct? {
        didSet {
            guard let product = product else { return }
            nameLabel.text = product.localizedTitle

            if RemoveAdsProduct.store.isProductPurchased(product.productIdentifier) {
                detailLabel.text = ""
                checkMarkImageView.isHidden = false
                detailLabel.isHidden = true
                rightArrowImageView.isHidden = true
            } else if IAPHelper.canMakePayments() {
                RemoveAdsCell.priceFormatter.locale = product.priceLocale
                detailLabel.text = RemoveAdsCell.priceFormatter.string(from: product.price)
                detailLabel.isHidden = false
                checkMarkImageView.isHidden = true
                rightArrowImageView.isHidden = false
            } else {
                detailLabel.text = "Not available".localized
                checkMarkImageView.isHidden = true
                detailLabel.isHidden = false
                rightArrowImageView.isHidden = true
            }
        }
    }

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        return label
    }()

    lazy var rightArrowImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.greyFontColor
        imageView.image = UIImage(named: "button_rightArrow")?.withRenderingMode(.alwaysTemplate)
    }

    lazy var checkMarkImageView = UIImageView().then { imageView in
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor.systemGreen
        imageView.image = UIImage(named: "icon_checkMark")?.withRenderingMode(.alwaysTemplate)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear

        contentView.addSubview(nameLabel)
        contentView.addSubview(detailLabel)
        contentView.addSubview(rightArrowImageView)
        contentView.addSubview(checkMarkImageView)

        nameLabel.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(detailLabel.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }

        detailLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(rightArrowImageView.snp.left).offset(-12)
        }

        rightArrowImageView.snp.makeConstraints { make in
            make.width.equalTo(12)
            make.right.equalToSuperview().inset(20)
            make.centerY.equalToSuperview()
        }

        checkMarkImageView.snp.makeConstraints { make in
            make.size.equalTo(20)
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(20)
        }
        checkMarkImageView.isHidden = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

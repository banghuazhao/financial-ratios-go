//
//  FRGHeaderView.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/12/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SnapKit
import UIKit

class FRGHeaderView: UITableViewHeaderFooterView {
    var sectionTitle: String? {
        didSet {
            sectionTitleLabel.text = sectionTitle
            if let sectionTitle = sectionTitle {
                let sectionTitleLabelWidth = sectionTitle.size(withAttributes: [NSAttributedString.Key.font: sectionTitleFont as Any]).width
                sectionTitleLabel.snp.updateConstraints { make in
                    make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
                    make.centerY.equalTo(contentView)
                    make.width.equalTo(sectionTitleLabelWidth)
                }
                layoutIfNeeded()
            }
        }
    }

    var isStatic: Bool = true {
        didSet {
            if !isStatic {
                loadingSpinner.startAnimating()
                loadingLabel.isHidden = false
            }
        }
    }

    var section: Int = 0

    var wrongType: FetchError?

    let sectionTitleLabel: UILabel = {
        let label = UILabel()
        label.font = sectionTitleFont
        label.textColor = .black
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let loadingSpinner: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .greyFont2Color
        indicator.hidesWhenStopped = true
        return indicator
    }()

    let loadingLabel: UILabel = {
        let label = UILabel()
        label.textColor = .greyFont2Color
        label.text = "Downloading...".localized
        label.font = dataRowTextFont
        return label
    }()

    let correctMarker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "check-circle-solid")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let correctLabel: UILabel = {
        let label = UILabel()
        label.textColor = .correctMarkColor
        label.text = "Download Successfully!".localized
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    let wrongMarker: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "times-circle-solid")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    let wrongLabel: UILabel = {
        let label = UILabel()
        label.textColor = .red
        label.text = "Error!".localized
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundView = UIView(frame: self.bounds)
        self.backgroundView?.backgroundColor = .headerViewColor
        
        contentView.backgroundColor = .headerViewColor
        contentView.addSubview(sectionTitleLabel)

        sectionTitleLabel.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.width.equalTo(100)
            make.centerY.equalTo(contentView)
        }

        contentView.addSubviews(loadingSpinner, loadingLabel, correctMarker, correctLabel, wrongMarker, wrongLabel)

        loadingSpinner.snp.makeConstraints { make in
            make.left.equalTo(sectionTitleLabel.snp.right).offset(8)
            make.size.equalTo(markerSize)
            make.centerY.equalTo(contentView)
        }

        loadingLabel.snp.makeConstraints { make in
            make.left.equalTo(loadingSpinner.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        correctMarker.snp.makeConstraints { make in
            make.left.equalTo(sectionTitleLabel.snp.right).offset(8)
            make.height.width.equalTo(markerSize)
            make.centerY.equalTo(contentView)
        }

        correctLabel.snp.makeConstraints { make in
            make.left.equalTo(correctMarker.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        wrongMarker.snp.makeConstraints { make in
            make.left.equalTo(sectionTitleLabel.snp.right).offset(8)
            make.height.width.equalTo(markerSize)
            make.centerY.equalTo(contentView)
        }

        wrongLabel.snp.makeConstraints { make in
            make.left.equalTo(wrongMarker.snp.right).offset(8)
            make.right.equalTo(contentView).offset(-dataRowLeftRightSpace)
            make.centerY.equalTo(contentView)
        }

        loadingSpinner.isHidden = true
        loadingLabel.isHidden = true
        correctMarker.isHidden = true
        correctLabel.isHidden = true
        wrongMarker.isHidden = true
        wrongLabel.isHidden = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  CompnayCell.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/9/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

import Kingfisher

class CompanyCell: UITableViewCell {
    
    var fetchImageTask: URLSessionTask?
    
    var myCompany: MyCompany? {
        didSet {
            guard let myCompany = myCompany else { return }
            if let imageData = myCompany.logoImage {
                companyIconView.image = UIImage(data: imageData)
            }
            companyNameLabel.attributedText = nil
            companyCodeLabel.attributedText = nil
            companyNameLabel.text = myCompany.name
            companyCodeLabel.text = myCompany.symbol
        }
    }
    
    var cellCompany: Company? {
        didSet {
            guard let cellCompanyGuard = cellCompany else { return }
            companyNameLabel.attributedText = nil
            companyCodeLabel.attributedText = nil
            companyNameLabel.text = cellCompanyGuard.name
            companyCodeLabel.text = cellCompanyGuard.symbol
            
            let urlString = "https://financialmodelingprep.com/images-New-jpg/\(cellCompanyGuard.symbol).jpg".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            
            let pictureURL = URL(string: urlString)
            
            let imageSize = isIphone ? 64 : 88
            
            let processor = DownsamplingImageProcessor(size: CGSize(width: imageSize, height: imageSize))
            companyIconView.kf.indicatorType = .activity
            companyIconView.kf.setImage(
                with: pictureURL,
                placeholder: UIImage(named: "select_photo_empty"),
                options: [
                    .processor(processor),
                    .scaleFactor(UIScreen.main.scale),
                    .transition(.fade(0.6)),
                    .cacheOriginalImage,
                ]
            )
        }
    }
    
    var isUser: Bool = false
    
    var searchText: String = "" {
        didSet {
            if let companyName = cellCompany?.name, !isUser {
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: companyName)

                let range: NSRange = (companyName as NSString).range(of: searchText, options:  [NSString.CompareOptions.caseInsensitive])

                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.headerViewColor, range: range)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: dataRowTextFontSize), range: range)

                companyNameLabel.attributedText = attrString
            }
            
            if let companyCode = cellCompany?.symbol, !isUser {
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: companyCode)

                let range: NSRange = (companyCode as NSString).range(of: searchText, options:  [NSString.CompareOptions.caseInsensitive])

                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.headerViewColor, range: range)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: dataRowTextFontSize), range: range)

                companyCodeLabel.attributedText = attrString
            }
            
            if let companyName = myCompany?.name, isUser {
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: companyName)

                let range: NSRange = (companyName as NSString).range(of: searchText, options:  [NSString.CompareOptions.caseInsensitive])

                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.headerViewColor, range: range)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: dataRowTextFontSize), range: range)

                companyNameLabel.attributedText = attrString
            }
            
            if let companyCode = myCompany?.symbol, isUser {
                let attrString: NSMutableAttributedString = NSMutableAttributedString(string: companyCode)

                let range: NSRange = (companyCode as NSString).range(of: searchText, options:  [NSString.CompareOptions.caseInsensitive])

                attrString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.headerViewColor, range: range)
                attrString.addAttribute(NSAttributedString.Key.font, value: UIFont.boldSystemFont(ofSize: dataRowTextFontSize), range: range)

                companyCodeLabel.attributedText = attrString
            }
        }
    }

    lazy var companyIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .financialStatementColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    lazy var  companyNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = .black
        return label
    }()

    lazy var  companyCodeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.textColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .companyCellColor
        let leftInset = dataRowLeftRightSpace + companyRowHeight
        separatorInset = UIEdgeInsets(top: 0, left: leftInset, bottom: 0, right: 0)

        contentView.addSubviews(companyIconView, companyNameLabel, companyCodeLabel)

        companyIconView.snp.makeConstraints { make in
            make.left.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.width.equalTo(companyRowHeight - 16)
            make.height.equalTo(companyRowHeight - 16)
            make.centerY.equalTo(contentView)
        }

        companyNameLabel.snp.makeConstraints { make in
            make.left.equalTo(companyIconView.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView).offset(-0.2 * companyRowHeight)
        }

        companyCodeLabel.snp.makeConstraints { make in
            make.left.equalTo(companyIconView.snp.right).offset(dataRowLeftRightSpace)
            make.right.equalTo(contentView).offset(-8)
            make.centerY.equalTo(contentView).offset(0.2 * companyRowHeight)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

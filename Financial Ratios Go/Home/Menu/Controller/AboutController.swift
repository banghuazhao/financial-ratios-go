//
//  AboutViewController.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/7/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class aboutTitleLabel: UILabel {
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    init(parent: UIView) {
        super.init(frame: .zero)
        parent.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        leftAnchor.constraint(equalTo: parent.leftAnchor, constant: 12).isActive = true
        textColor = .greyFont2Color
        font = isIphone ? UIFont.systemFont(ofSize: 18, weight: .bold) : UIFont.systemFont(ofSize: 22, weight: .bold)
    }
}

class AboutController: UIViewController {
    let scrollView: UIScrollView = UIScrollView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .financialStatementColor

        navigationItem.title = "About this App".localized

        editLayout()
    }

    func editLayout() {
        view.addSubview(scrollView)

        scrollView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.bottomAnchor, trailing: view.trailingAnchor)

        let brandTitle: UILabel = UILabel()
        let brandTitleVersion: UILabel = UILabel()
        let introductionTitle: aboutTitleLabel = aboutTitleLabel(parent: scrollView)
        let introductions = UITextView()
        let privacyTitle: aboutTitleLabel = aboutTitleLabel(parent: scrollView)
        let privacy = UITextView()

        scrollView.addSubviews(brandTitle, brandTitleVersion, introductionTitle, introductions, privacyTitle, privacy)

        brandTitle.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 36).isActive = true
        brandTitle.translatesAutoresizingMaskIntoConstraints = false
        brandTitle.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        brandTitle.font = isIphone ? UIFont.systemFont(ofSize: 26, weight: .bold) : UIFont.systemFont(ofSize: 32, weight: .bold)
        brandTitle.text = "Financial Ratios Go".localized
        brandTitle.textColor = #colorLiteral(red: 0.9987751842, green: 0.7098405957, blue: 0.2326981425, alpha: 1)

        brandTitleVersion.topAnchor.constraint(equalTo: brandTitle.bottomAnchor, constant: 8).isActive = true
        brandTitleVersion.translatesAutoresizingMaskIntoConstraints = false
        brandTitleVersion.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        brandTitleVersion.text = "\("Version".localized) \(versionNum)"
        brandTitleVersion.font = isIphone ? UIFont.systemFont(ofSize: 16, weight: .bold) : UIFont.systemFont(ofSize: 20, weight: .bold)
        brandTitleVersion.textColor = .greyFont2Color

        introductionTitle.topAnchor.constraint(equalTo: brandTitleVersion.bottomAnchor, constant: 30).isActive = true
        introductionTitle.text = "∙ \("Introduction".localized)"

        introductions.translatesAutoresizingMaskIntoConstraints = false
        introductions.topAnchor.constraint(equalTo: introductionTitle.bottomAnchor, constant: 8).isActive = true
        introductions.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8).isActive = true
        introductions.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16).isActive = true
        introductions.text = "This App is a financial ratio calculator\n\nIt can fetch financial statements of 25000+ major companies from the American stock market by using API from https://financialmodelingprep.com/developer/docs/\n\nIt can also store user-defined financial statements and add fiscal period".localized
        introductions.isScrollEnabled = false
        introductions.isEditable = false
        introductions.dataDetectorTypes = UIDataDetectorTypes.all
        introductions.font = dataRowTextFont
        introductions.backgroundColor = .financialStatementColor

        privacyTitle.topAnchor.constraint(equalTo: introductions.bottomAnchor, constant: 24).isActive = true
        privacyTitle.text = "∙ \("Privacy".localized)"

        privacy.translatesAutoresizingMaskIntoConstraints = false
        privacy.topAnchor.constraint(equalTo: privacyTitle.bottomAnchor, constant: 8).isActive = true
        privacy.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 8).isActive = true
        privacy.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -16).isActive = true
        privacy.text = "https://apps-bay.github.io/Financial-Ratios-Go-Website/privacy/"
        privacy.isScrollEnabled = false
        privacy.isEditable = false
        privacy.dataDetectorTypes = UIDataDetectorTypes.all
        privacy.font = UIFont.systemFont(ofSize: 14)
        privacy.backgroundColor = .financialStatementColor
        privacy.textAlignment = .justified

        privacy.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -60).isActive = true
    }
}

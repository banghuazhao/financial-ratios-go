//
//  CreateNewCell.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class CreateNewCell: UITableViewCell {
    lazy var companyImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // remember to do this, otherwise image views by default are not interactive
        imageView.backgroundColor = .white
        return imageView
    }()

    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Name".localized
        label.textColor = .black
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter name".localized
        textField.textAlignment = .left
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = .black
        return textField
    }()

    lazy var symbolLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Symbol".localized
        label.textColor = .black
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var symbolTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter symbol".localized
        textField.textAlignment = .left
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = .black
        return textField
    }()

    lazy var fiscalPeriodLabel: UILabel = {
        let label = UILabel()
        label.text = "Fiscal Period".localized
        label.textColor = .black
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        return label
    }()

    lazy var fiscalPeriodSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Annually".localized, "Quarterly".localized])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .black
        return segmentedControl
    }()

    lazy var fiscalPeriodTime: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()

    lazy var datePicker: UIDatePicker = {
        let dp = UIDatePicker()
        if #available(iOS 14, *) {
            dp.preferredDatePickerStyle = .wheels
        }
        dp.datePickerMode = .date
        dp.translatesAutoresizingMaskIntoConstraints = false
        dp.addTarget(self, action: #selector(datePickerChanged(sender:)), for: .valueChanged)
        dp.setValue(UIColor.black, forKey: "textColor")
        return dp
    }()

    @objc func datePickerChanged(sender: UIDatePicker) {
        fiscalPeriodTime.text = dateFormater(datePicker: sender)
    }

    private func dateFormater(datePicker: UIDatePicker) -> String {
        let formatter: DateFormatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: datePicker.date)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        selectionStyle = .none
        backgroundColor = .financialStatementColor

        addSubview(companyImageView)

        companyImageView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(contentView).offset(dataRowLeftRightSpace)
            make.centerX.equalToSuperview()
        }

        addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(dataRowLeftRightSpace)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        addSubview(nameTextField)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(dataRowLeftRightSpace)
            make.left.equalTo(nameLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }

        addSubview(symbolLabel)

        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        addSubview(symbolTextField)

        symbolTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(symbolLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }

        addSubview(fiscalPeriodLabel)

        fiscalPeriodLabel.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        addSubview(fiscalPeriodSegmentedControl)

        fiscalPeriodSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(symbolLabel.snp.bottom)
            make.left.equalTo(symbolLabel.snp.right).offset(16)
            make.width.equalTo(160)
            make.height.equalTo(35)
        }

        addSubview(fiscalPeriodTime)
        fiscalPeriodTime.snp.makeConstraints { make in
            make.left.equalTo(fiscalPeriodSegmentedControl)
            make.width.equalTo(160)
            make.top.equalTo(fiscalPeriodSegmentedControl.snp.bottom)
            make.height.equalTo(35)
        }
        fiscalPeriodTime.text = dateFormater(datePicker: datePicker)

        // setup the date picker here

        addSubview(datePicker)
        datePicker.topAnchor.constraint(equalTo: fiscalPeriodTime.bottomAnchor).isActive = true
        datePicker.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        datePicker.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 160).isActive = true
        datePicker.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        if fiscalPeriodLabel.text == "Fiscal Period" {
            let loc = Locale(identifier: "en")
            datePicker.locale = loc
        } else {
            let loc = Locale(identifier: "zh-Hans")
            datePicker.locale = loc
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

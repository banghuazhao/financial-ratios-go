//
//  CreateOrEditFiscalPeriodCell.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class CreateOrEditFiscalPeriodCell: UITableViewCell, UIImagePickerControllerDelegate {
    var fiscalPeriodLabel: UILabel = {
        let label = UILabel()
        label.text = "Fiscal Period".localized
        // enable autolayout
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.textColor = .black
        return label
    }()

    var fiscalPeriodSegmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Annually".localized, "Quarterly".localized])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.tintColor = .black
        return segmentedControl
    }()

    var fiscalPeriodTime: UILabel = {
        let label = UILabel()
        label.sizeToFit()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.textAlignment = .left
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
        
        
        contentView.addSubview(fiscalPeriodLabel)

        fiscalPeriodLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(dataRowLeftRightSpace)
            make.left.equalToSuperview().inset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        contentView.addSubview(fiscalPeriodSegmentedControl)

        fiscalPeriodSegmentedControl.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(dataRowLeftRightSpace)
            make.left.equalTo(fiscalPeriodLabel.snp.right).offset(16)
            make.width.equalTo(160)
            make.height.equalTo(35)
        }

        contentView.addSubview(fiscalPeriodTime)

        fiscalPeriodTime.snp.makeConstraints { make in
            make.left.equalTo(fiscalPeriodSegmentedControl)
            make.width.equalTo(160)
            make.top.equalTo(fiscalPeriodSegmentedControl.snp.bottom)
            make.height.equalTo(35)
        }

        fiscalPeriodTime.text = dateFormater(datePicker: datePicker)

        // setup the date picker here

        contentView.addSubview(datePicker)
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

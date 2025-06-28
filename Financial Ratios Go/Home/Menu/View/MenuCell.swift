//
//  ManuCell.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/6/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import UIKit

class MenuCell: UITableViewCell {
    var menuModel: MenuModel? {
        didSet {
            guard let menuModel = menuModel else {
                return
            }
            menuImageView.image = menuModel.image.withRenderingMode(.alwaysTemplate)
            nameLabel.text = menuModel.name.localized
        }
    }

    let menuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(displayP3Red: 165 / 255, green: 172 / 255, blue: 179 / 255, alpha: 1.0)
        return imageView
    }()

    let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = dataRowTextFont
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = .financialStatementColor
        accessoryType = .disclosureIndicator

        contentView.addSubview(menuImageView)
        menuImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: dataRowLeftRightSpace).isActive = true
        menuImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        menuImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        menuImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true

        contentView.addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: menuImageView.rightAnchor, constant: dataRowLeftRightSpace).isActive = true
        nameLabel.widthAnchor.constraint(equalTo: widthAnchor, constant: -120).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: menuImageView.centerYAnchor, constant: 0).isActive = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

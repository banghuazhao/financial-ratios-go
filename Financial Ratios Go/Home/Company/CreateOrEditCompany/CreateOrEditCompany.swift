//
//  EditCompanyViewController.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import CoreData
import UIKit

protocol CreateOrEditCompanyControllerDelegate {
    func didCreateCompany(myCompany: MyCompany)
    func didEditCompany(myCompany: MyCompany)
}

class CreateOrEditCompanyController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    var delegate: CreateOrEditCompanyControllerDelegate?

    var myCompany: MyCompany? {
        didSet {
            if let imageData = myCompany?.logoImage {
                companyImageView.image = UIImage(data: imageData)
            }
            nameTextField.text = myCompany?.name
            symbolTextField.text = myCompany?.symbol
        }
    }

    var sectionHeight: CGFloat = 42
    var companyRowHeigt: CGFloat = 76
    var statementRowHeight: CGFloat = 36

    let scrollView = UIScrollView()

    let lightBlueBackgroundView = UIView()

    lazy var companyImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "select_photo_empty"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true // remember to do this, otherwise image views by default are not interactive
        imageView.backgroundColor = .white
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))

        return imageView
    }()

    @objc private func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            companyImageView.image = editedImage

        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            companyImageView.image = originalImage
        }

        dismiss(animated: true, completion: nil)
    }

    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Name".localized
        // enable autolayout
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter name".localized
        textField.textAlignment = .left
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = .black
        return textField
    }()

    let symbolLabel: UILabel = {
        let label = UILabel()
        label.text = "Company Symbol".localized
        // enable autolayout
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()

    let symbolTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter symbol".localized
        textField.textAlignment = .left
        textField.adjustsFontSizeToFitWidth = true
        textField.textColor = .black
        return textField
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupUI() {
        if myCompany == nil {
            navigationItem.title = "Create Company".localized
        } else {
            navigationItem.title = "Edit Company".localized
        }

        view.backgroundColor = UIColor.backgroundColor

        setupCancelButton()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized, style: .plain, target: self, action: #selector(handleSave))

        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true

        scrollView.addSubview(lightBlueBackgroundView)
        lightBlueBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        lightBlueBackgroundView.backgroundColor = UIColor.financialStatementColor
        lightBlueBackgroundView.topAnchor.constraint(equalTo: scrollView.topAnchor).isActive = true
        lightBlueBackgroundView.leftAnchor.constraint(equalTo: scrollView.leftAnchor).isActive = true
        lightBlueBackgroundView.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true

        lightBlueBackgroundView.addSubview(companyImageView)

        companyImageView.snp.makeConstraints { make in
            make.size.equalTo(100)
            make.top.equalTo(lightBlueBackgroundView.snp.top).offset(dataRowLeftRightSpace)
            make.centerX.equalToSuperview()
        }

        lightBlueBackgroundView.addSubview(nameLabel)

        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(dataRowLeftRightSpace)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        lightBlueBackgroundView.addSubview(nameTextField)

        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(companyImageView.snp.bottom).offset(dataRowLeftRightSpace)
            make.left.equalTo(nameLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }

        lightBlueBackgroundView.addSubview(symbolLabel)

        symbolLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().multipliedBy(0.5).offset(-8)
            make.height.equalTo(35)
        }

        lightBlueBackgroundView.addSubview(symbolTextField)

        symbolTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalTo(symbolLabel.snp.right).offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(35)
        }

        symbolLabel.bottomAnchor.constraint(equalTo: lightBlueBackgroundView.bottomAnchor, constant: -12).isActive = true

        lightBlueBackgroundView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -40).isActive = true
    }

    @objc private func handleSave() {
        if myCompany == nil {
            createCompany()
        } else {
            editCompany()
        }
    }

    func createCompany() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let myCompany = NSEntityDescription.insertNewObject(forEntityName: "MyCompany", into: context) as! MyCompany

        myCompany.name = nameTextField.text
        myCompany.symbol = symbolTextField.text

        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 0.8)
            myCompany.logoImage = imageData
        }

        // perform the save
        do {
            try context.save()

            // success
            dismiss(animated: true, completion: {
                self.delegate?.didCreateCompany(myCompany: myCompany)
            })

        } catch let saveErr {
            print("Failed to save company:", saveErr)
        }
    }

    func editCompany() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        myCompany?.name = nameTextField.text
        myCompany?.symbol = symbolTextField.text

        if let companyImage = companyImageView.image {
            let imageData = companyImage.jpegData(compressionQuality: 0.8)
            myCompany?.logoImage = imageData
        }

        do {
            try context.save()

            // save succeeded
            dismiss(animated: true, completion: {
                self.delegate?.didEditCompany(myCompany: self.myCompany!)
            })

        } catch let saveErr {
            print("Failed to save company changes:", saveErr)
        }
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

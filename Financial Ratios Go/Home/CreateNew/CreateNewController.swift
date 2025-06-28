//
//  CreateNewController.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/26/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import CoreData
import UIKit

protocol CreateNewControllerDelegate {
    func didCreateNew()
}

class CreateNewController: FRGViewController {
    var delegate: CreateNewControllerDelegate?
    
    var createNewCell = CreateNewCell()

    var incomeStatementValuesNew = FinancialStatement.incomeStatementValues
    var balanceSheetStatementValuesNew = FinancialStatement.balanceSheetStatementValues
    var cashFlowStatementValuesNew = FinancialStatement.cashFlowStatementValues

    var loadCurrentStatement: Bool = false {
        didSet {
            guard let image = UIImage(data: company.logoImage) else { return }
            createNewCell.companyImageView.image = image
            createNewCell.nameTextField.text = company.name
            createNewCell.symbolTextField.text = company.symbol
            createNewCell.fiscalPeriodSegmentedControl.selectedSegmentIndex = fiscalPeriod.period == "Annually" ? 0 : 1
            createNewCell.fiscalPeriodTime.text = fiscalPeriod.time
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let date = dateFormatter.date(from: fiscalPeriod.time)!
            createNewCell.datePicker.date = date
            tableView.reloadData()
        }
    }

    let headerViews: [FRGHeaderView] = {
        var headerViews: [FRGHeaderView] = []
        for (section, homeSectionHeader) in createCompanySectionHeaders.enumerated() {
            let headerView = FRGHeaderView()
            headerView.sectionTitle = homeSectionHeader.title.localized
            headerView.isStatic = homeSectionHeader.isStatic
            headerView.section = section
            headerViews.append(headerView)
        }
        return headerViews
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        tableView.register(CreateNewCell.self, forCellReuseIdentifier: "CreateNewCell")
        tableView.register(FinancialStatementCell.self, forCellReuseIdentifier: "DataCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .backgroundColor

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupViews()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupNav() {
        navigationItem.title = "Create Company".localized
        setupCancelButton()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized, style: .plain, target: self, action: #selector(createCompany))
    }

    func setupViews() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: actions

extension CreateNewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @objc private func handleSelectPhoto() {
        let imagePickerController = UIImagePickerController()

        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .navBarColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]

            imagePickerController.navigationController?.navigationBar.tintColor = .white
            imagePickerController.navigationController?.navigationBar.standardAppearance = appearance
            imagePickerController.navigationController?.navigationBar.compactAppearance = appearance
            imagePickerController.navigationController?.navigationBar.scrollEdgeAppearance = appearance

        } else {
            imagePickerController.navigationController?.navigationBar.tintColor = .white
            imagePickerController.navigationController?.navigationBar.barTintColor = .navBarColor
            imagePickerController.navigationController?.navigationBar.isTranslucent = false
        }

        present(imagePickerController, animated: true, completion: nil)
    }

    @objc func cancelPicker() {
        dismiss(animated: true, completion: nil)
    }

    @objc func createCompany() {
        isHomeFetchOnlineData = false

        company.name = ""
        company.symbol = ""
        company.logoImage = Data()
        fiscalPeriod.time = ""
        fiscalPeriod.period = ""
        
        FinancialStatement.initializeFinancialStatement()
        
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let myCompany = NSEntityDescription.insertNewObject(forEntityName: "MyCompany", into: context) as! MyCompany

        tableView.reloadData()

        if let name = createNewCell.nameTextField.text {
            myCompany.setValue(name, forKey: "name")
            company.name = name
        }

        if let symbol = createNewCell.symbolTextField.text {
            myCompany.setValue(symbol, forKey: "symbol")
            company.symbol = symbol
        }

        if let companyImage = createNewCell.companyImageView.image {
            if let imageData = companyImage.jpegData(compressionQuality: 0.8) {
                myCompany.setValue(imageData, forKey: "logoImage")
                company.logoImage = imageData
            }
        }

        let myFiscalPeriod = NSEntityDescription.insertNewObject(forEntityName: "MyFiscalPeriod", into: context) as! MyFiscalPeriod

        myFiscalPeriod.company = myCompany

        if let period = createNewCell.fiscalPeriodSegmentedControl.titleForSegment(at: createNewCell.fiscalPeriodSegmentedControl.selectedSegmentIndex) {
            myFiscalPeriod.period = period
            fiscalPeriod.period = period
        }

        if let time = createNewCell.fiscalPeriodTime.text {
            myFiscalPeriod.time = time
            fiscalPeriod.time = time
        }

        let myFinancialStatement = NSEntityDescription.insertNewObject(forEntityName: "MyFinancialStatement", into: context) as! MyFinancialStatement

        myFinancialStatement.fiscalPeriod = myFiscalPeriod

        myFinancialStatement.incomeStatement = incomeStatementValuesNew as NSObject
        myFinancialStatement.balanceSheetStatement = balanceSheetStatementValuesNew as NSObject
        myFinancialStatement.cashFlowStatement = cashFlowStatementValuesNew as NSObject

        incomeStatementValues = incomeStatementValuesNew
        balanceSheetStatementValues = balanceSheetStatementValuesNew
        cashFlowStatementValues = cashFlowStatementValuesNew

        // perform the save
        do {
            try context.save()

            // success
            dismiss(animated: true, completion: {
                self.delegate?.didCreateNew()
            })

        } catch let saveErr {
            print("Failed to save company:", saveErr)
        }
    }

    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK:

extension CreateNewController {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            createNewCell.companyImageView.image = editedImage
            tableView.reloadData()

        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            createNewCell.companyImageView.image = originalImage
            tableView.reloadData()
        }

        dismiss(animated: true, completion: nil)
    }
}

// MARK: UITableViewDelegate and UITableViewDataSource

extension CreateNewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }

        return sectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()

        return footerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return incomeStatementLabels.count
        case 2:
            return balanceSheetStatementLabels.count
        case 3:
            return cashFlowStatementLabels.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 408
        }
        return statementRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            createNewCell.companyImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleSelectPhoto)))

            return createNewCell

        case 1:
            let incomeStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            incomeStatementCell.financialDataLabel.text = incomeStatementLabels[indexPath.row].localized
            incomeStatementCell.financialDataTextField.text = convertStringToCurrency(amount: incomeStatementValuesNew[incomeStatementLabelsMapping[incomeStatementLabels[indexPath.row]]!] ?? "")
            incomeStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            incomeStatementCell.financialDataTextField.delegate = self

            return incomeStatementCell
        case 2:
            let balanceSheetStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            balanceSheetStatementCell.financialDataLabel.text = balanceSheetStatementLabels[indexPath.row].localized
            balanceSheetStatementCell.financialDataTextField.text = convertStringToCurrency(amount: balanceSheetStatementValuesNew[balanceSheetStatementLabelsMapping[balanceSheetStatementLabels[indexPath.row]]!] ?? "")
            balanceSheetStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            balanceSheetStatementCell.financialDataTextField.delegate = self

            return balanceSheetStatementCell
        case 3:
            let cashFlowStatementCell = tableView.dequeueReusableCell(withIdentifier: "DataCell", for: indexPath) as! FinancialStatementCell

            cashFlowStatementCell.financialDataLabel.text = cashFlowStatementLabels[indexPath.row].localized
            cashFlowStatementCell.financialDataTextField.text = convertStringToCurrency(amount: cashFlowStatementValuesNew[cashFlowStatementLabelsMapping[cashFlowStatementLabels[indexPath.row]]!] ?? "")
            cashFlowStatementCell.financialDataTextField.placeholder = "Enter Value".localized
            cashFlowStatementCell.financialDataTextField.delegate = self

            return cashFlowStatementCell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FinancialStatementCell

        explainBox.setContent(title: cell.financialDataLabel.text!, message: ExplainModel().financialStatementExplain[cell.financialDataLabel.text!]!)

        present(explainBox, animated: false, completion: nil)
    }
}

// MARK: - UITextFieldDelegate

extension CreateNewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.textColor = .black

        let currency = convertStringToCurrency(amount: textField.text ?? "")

        if isCorrectCurrency(textField: textField) {
            textField.text = currency
        } else {
            textField.textColor = .red
        }

        if let cell = textField.superview?.superview as? FinancialStatementCell {
            let indexPath = tableView.indexPath(for: cell)
            switch indexPath?.section {
            case 1:
                incomeStatementValuesNew[incomeStatementAPI[indexPath!.row]] = textField.text ?? ""
            case 2:
                balanceSheetStatementValuesNew[balanceSheetStatementAPI[indexPath!.row]] = textField.text ?? ""
            case 3:
                cashFlowStatementValuesNew[cashFlowStatementAPI[indexPath!.row]] = textField.text ?? ""
            default:
                break
            }
        }
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.textColor = UIColor(displayP3Red: 0.5, green: 0.5, blue: 0.5, alpha: 1)
    }

    func isCorrectCurrency(textField: UITextField) -> Bool {
        let currency = convertStringToCurrency(amount: textField.text ?? "")

        guard let _ = convertCurrencyToDouble(input: currency) else {
            return false
        }

        return true
    }
}

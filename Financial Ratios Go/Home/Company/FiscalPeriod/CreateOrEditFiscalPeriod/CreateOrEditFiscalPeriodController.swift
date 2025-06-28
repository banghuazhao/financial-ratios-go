//
//  CreateOrEditFiscalPeriodController.swift
//  Finance Ratio Calculator
//
//  Created by Banghua Zhao on 9/27/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import CoreData
import UIKit

protocol CreateOrEditFiscalPeriodControllerDelegate {
    func didAddFiscalPeriod(myFiscalPeriod: MyFiscalPeriod)
    func didEditFiscalPeriod(myFiscalPeriod: MyFiscalPeriod, indexPath: IndexPath)
}

class CreateOrEditFiscalPeriodController: UITableViewController, UINavigationControllerDelegate {
    var incomeStatementValuesNew = FinancialStatement.incomeStatementValues

    var balanceSheetStatementValuesNew = FinancialStatement.balanceSheetStatementValues

    var cashFlowStatementValuesNew = FinancialStatement.cashFlowStatementValues

    var delegate: CreateOrEditFiscalPeriodControllerDelegate?
    
    var indexPath: IndexPath?

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

    var myFiscalPeriod: MyFiscalPeriod? {
        didSet {
            let cell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! CreateOrEditFiscalPeriodCell
            if myFiscalPeriod?.period == "Annually" {
                cell.fiscalPeriodSegmentedControl.selectedSegmentIndex = 0
            } else {
                cell.fiscalPeriodSegmentedControl.selectedSegmentIndex = 1
            }

            if let dateString = myFiscalPeriod?.time {
                cell.fiscalPeriodTime.text = dateString
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date = dateFormatter.date(from: dateString)!
                cell.datePicker.date = date
            }

            incomeStatementValuesNew = myFiscalPeriod?.financialStatement?.incomeStatement as! [String: String]
            balanceSheetStatementValuesNew = myFiscalPeriod?.financialStatement?.balanceSheetStatement as! [String: String]
            cashFlowStatementValuesNew = myFiscalPeriod?.financialStatement?.cashFlowStatement as! [String: String]

            tableView.reloadData()
        }
    }

    var myCompany: MyCompany?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    private func setupUI() {
        tableView = UITableView(frame: .zero)

        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        if myFiscalPeriod == nil {
            navigationItem.title = "Create Fiscal Period".localized
        } else {
            navigationItem.title = "Edit Fiscal Period".localized
        }

        view.backgroundColor = UIColor.backgroundColor

        setupCancelButton()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save".localized, style: .plain, target: self, action: #selector(handleSave))

        tableView.register(CreateOrEditFiscalPeriodCell.self, forCellReuseIdentifier: "CreateOrEditFiscalPeriodCell")
        tableView.register(FinancialStatementCell.self, forCellReuseIdentifier: "DataCell")
    }

    @objc private func handleSave() {
        if myFiscalPeriod == nil {
            createFiscalPeriod()
        } else {
            editFiscalPeriod()
        }
    }

    func createFiscalPeriod() {
        let context = CoreDataManager.shared.persistentContainer.viewContext

        let myFiscalPeriod = NSEntityDescription.insertNewObject(forEntityName: "MyFiscalPeriod", into: context) as! MyFiscalPeriod

        myFiscalPeriod.company = myCompany

        tableView.reloadData()

        let cell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! CreateOrEditFiscalPeriodCell

        if cell.fiscalPeriodSegmentedControl.selectedSegmentIndex == 0 {
            myFiscalPeriod.period = "Annually"
        } else {
            myFiscalPeriod.period = "Quarterly"
        }

        if let time = cell.fiscalPeriodTime.text {
            myFiscalPeriod.time = time
        }

        let myFinancialStatement = NSEntityDescription.insertNewObject(forEntityName: "MyFinancialStatement", into: context) as! MyFinancialStatement

        myFinancialStatement.fiscalPeriod = myFiscalPeriod
        myFinancialStatement.incomeStatement = incomeStatementValuesNew as NSObject
        myFinancialStatement.balanceSheetStatement = balanceSheetStatementValuesNew as NSObject
        myFinancialStatement.cashFlowStatement = cashFlowStatementValuesNew as NSObject

        // perform the save
        do {
            try context.save()

            // success
            dismiss(animated: true, completion: {
                self.delegate?.didAddFiscalPeriod(myFiscalPeriod: myFiscalPeriod)
            })

        } catch let saveErr {
            print("Failed to save company:", saveErr)
        }
    }

    func editFiscalPeriod() {
        tableView.reloadData()

        let cell = tableView(tableView, cellForRowAt: IndexPath(row: 0, section: 0)) as! CreateOrEditFiscalPeriodCell

        let context = CoreDataManager.shared.persistentContainer.viewContext

        if cell.fiscalPeriodSegmentedControl.selectedSegmentIndex == 0 {
            myFiscalPeriod?.period = "Annually"
        } else {
            myFiscalPeriod?.period = "Quarterly"
        }

        if let time = cell.fiscalPeriodTime.text {
            myFiscalPeriod?.time = time
        }

        myFiscalPeriod?.financialStatement?.fiscalPeriod = myFiscalPeriod
        myFiscalPeriod?.financialStatement?.incomeStatement = incomeStatementValuesNew as NSObject
        myFiscalPeriod?.financialStatement?.balanceSheetStatement = balanceSheetStatementValuesNew as NSObject
        myFiscalPeriod?.financialStatement?.cashFlowStatement = cashFlowStatementValuesNew as NSObject

        do {
            try context.save()

            // save succeeded
            dismiss(animated: true, completion: {
                
                // TODO
                self.delegate?.didEditFiscalPeriod(myFiscalPeriod: self.myFiscalPeriod!, indexPath: self.indexPath!)
            })

        } catch let saveErr {
            print("Failed to save company changes:", saveErr)
        }
    }
}

extension CreateOrEditFiscalPeriodController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        return sectionHeight
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()

        return footerView
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 238
        }
        return statementRowHeight
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let topCell = tableView.dequeueReusableCell(withIdentifier: "CreateOrEditFiscalPeriodCell", for: indexPath) as! CreateOrEditFiscalPeriodCell

            return topCell

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

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FinancialStatementCell

        explainBox.setContent(title: cell.financialDataLabel.text!, message: ExplainModel().financialStatementExplain[cell.financialDataLabel.text!]!)

        present(explainBox, animated: false, completion: nil)
    }
}

extension CreateOrEditFiscalPeriodController: UITextFieldDelegate {
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

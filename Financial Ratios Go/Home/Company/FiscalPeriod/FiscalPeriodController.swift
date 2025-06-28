//
//  FinancialTimeViewController.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/18/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//
#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import UIKit

var financialTimesAnnually: [FiscalPeriod]? = [FiscalPeriod]()
var financialTimesQuarterly: [FiscalPeriod]? = [FiscalPeriod]()

protocol FiscalPeriodControllerDelegate {
    func didSelectedFiscalPeriod()
}

class FiscalPeriodController: FRGViewController {
    var delegate: FiscalPeriodControllerDelegate?

    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    var newCompany: Company?
    var myNewCompany: MyCompany?
    var myFiscalPeriodAnnually = [MyFiscalPeriod]()
    var myFiscalPeriodQuarterly = [MyFiscalPeriod]()
    var isLocalCompany: Bool = false
    var selectedIndexPaths: [IndexPath]?
    var selectedNumbers = 0
    var firstPath: IndexPath?

    let headerViews: [FRGHeaderView] = {
        var headerViews: [FRGHeaderView] = []
        for (section, homeSectionHeader) in fiscalPeriodSectionHeaders.enumerated() {
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
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))
        
        if #available(iOS 15.0, *) {
            #if !targetEnvironment(macCatalyst)
                tableView.sectionHeaderTopPadding = 0
            #endif
        }

        tableView.register(FiscalPeriodCell.self, forCellReuseIdentifier: "FiscalPeriodCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .backgroundColor

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        if !isSingle {
            tableView.allowsMultipleSelection = true
        }

        isHomeFetchOnlineData = false

        setupNav()

        setupView()

        #if !targetEnvironment(macCatalyst)
            if RemoveAdsProduct.store.isProductPurchased(RemoveAdsProduct.removeAdsProductIdentifier) {
                print("Previously purchased: \(RemoveAdsProduct.removeAdsProductIdentifier)")
            } else {
                view.addSubview(bannerView)
                bannerView.snp.makeConstraints { make in
                    make.height.equalTo(50)
                    make.width.equalToSuperview()
                    make.bottom.equalTo(view.safeAreaLayoutGuide)
                    make.centerX.equalToSuperview()
                }
            }
        #endif

        if !isLocalCompany {
            setupRefresh()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    func setupNav() {
        navigationItem.title = "Fiscal Period".localized
    }

    // MARK: - setupView

    func setupView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if isLocalCompany {
            hideHeaderIndictors(headerViews: headerViews)
            (myFiscalPeriodAnnually, myFiscalPeriodQuarterly) = CoreDataManager.shared.fetchLocalFiscalPeriod(myCompany: myNewCompany)
            let item1 = UIBarButtonItem(title: "Edit".localized, style: .plain, target: self, action: #selector(showEditing))
            let item2 = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .plain, target: self, action: #selector(addFiscalPeriod))
            navigationItem.rightBarButtonItems = [item1, item2]
        } else {
            beginFetchFinancialPeriod()
        }
    }

    fileprivate func beginFetchFinancialPeriod() {
        showLoading(headerViews: headerViews)

        financialTimesAnnually = []
        financialTimesQuarterly = []

        let fetchPlaces = ["Annually", "Quarterly"]

        for i in 0 ... fetchPlaces.count - 1 {
            if !readFiscalPeriodFromLocal(newCompany: newCompany ?? company, period: fetchPlaces[i]) {
                fetchFinanicalPeriod(newCompany: newCompany ?? company, period: fetchPlaces[i]) { result in
                    DispatchQueue.main.async {
                        let headerView = self.headerViews[i]
                        switch result {
                        case .success:
                            showSuccess(headerViews: [headerView])
                            self.tableView.reloadData()
                            self.tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
                        case let .failure(fetchError):
                            if fetchError.rawValue != "Network is Cancelled!" {
                                showError(headerViews: [headerView], errorDiscription: fetchError.rawValue.localized)
                                headerView.wrongType = fetchError
                            }
                        }
                    }
                }
            } else {
                let headerView = headerViews[i]
                showSuccess(headerViews: [headerView])
                tableView.reloadData()
                tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
            }
        }
    }

    func readAllLocalFiscialPeriodData() -> Bool {
        var readTime: Int = 0
        let fetchPlaces = ["Annually", "Quarterly"]
        for i in 0 ... fetchPlaces.count - 1 {
            if readFiscalPeriodFromLocal(newCompany: newCompany ?? company, period: fetchPlaces[i]) {
                let headerView = headerViews[i]
                showSuccess(headerViews: [headerView])
                tableView.reloadData()
                tableView.reloadSections(IndexSet(arrayLiteral: headerView.section), with: .automatic)
                readTime += 1
            }
        }
        if readTime == 2 {
            return true
        } else {
            return false
        }
    }

    func setupRefresh() {
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Pull to refresh".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        tableView.refreshControl!.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
    }

    @objc func refresh() {
        if !readAllLocalFiscialPeriodData() {
            tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Redownloading data...".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            beginFetchFinancialPeriod()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.tableView.refreshControl!.endRefreshing()
            })
        } else {
            tableView.refreshControl!.attributedTitle = NSAttributedString(string: "Refresh finished".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
            tableView.refreshControl!.endRefreshing()
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !(tableView.refreshControl?.isRefreshing ?? false) {
            tableView.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh".localized, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        }
    }
}

// MARK: actions

extension FiscalPeriodController {
    @objc private func addFiscalPeriod() {
        let addFiscalPeriodController = CreateOrEditFiscalPeriodController()

        let navController = FRGNavigationController(rootViewController: addFiscalPeriodController)

        addFiscalPeriodController.myCompany = myNewCompany

        addFiscalPeriodController.delegate = self

        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true, completion: nil)
    }

    @objc private func showEditing() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItems?[0].title = "Edit".localized
        } else {
            tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItems?[0].title = "Done".localized
        }
    }
}

// MARK: - Table view data source

extension FiscalPeriodController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return fiscalPeriodSectionHeaders.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionHeight
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return headerViews[section]
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if section == 0 {
            label.text = "No annually fiscal peroid available...".localized
        } else {
            label.text = "No quarterly fiscal peroid available...".localized
        }
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        return label
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isLocalCompany {
            if section == 0 {
                return myFiscalPeriodAnnually.count == 0 ? 80 : 0
            } else {
                return myFiscalPeriodQuarterly.count == 0 ? 80 : 0
            }
        } else {
            if section == 0 {
                return financialTimesAnnually?.count == 0 ? 80 : 0
            } else {
                return financialTimesQuarterly?.count == 0 ? 80 : 0
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if isSingle {
                if isLocalCompany {
                    return myFiscalPeriodAnnually.count
                } else {
                    return financialTimesAnnually?.count ?? 0
                }
            } else {
                if let selectedIndexPaths = selectedIndexPaths, selectedIndexPaths.count > 0, selectedIndexPaths[0].section == 1 {
                    return 0
                } else {
                    if isLocalCompany {
                        return myFiscalPeriodAnnually.count
                    } else {
                        return financialTimesAnnually?.count ?? 0
                    }
                }
            }
        case 1:
            if let selectedIndexPaths = selectedIndexPaths, selectedIndexPaths.count > 0, selectedIndexPaths[0].section == 0 {
                return 0
            } else {
                if isLocalCompany {
                    return myFiscalPeriodQuarterly.count
                } else {
                    return financialTimesQuarterly?.count ?? 0
                }
            }
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return statementRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FiscalPeriodCell", for: indexPath) as! FiscalPeriodCell
        cell.accessoryType = .none
        #if !targetEnvironment(macCatalyst)
            selectedIndexPaths = tableView.indexPathsForSelectedRows
            if let selectedIndexPaths = selectedIndexPaths {
                for selectedIndexPath in selectedIndexPaths {
                    if indexPath == selectedIndexPath {
                        cell.accessoryType = .checkmark
                        break
                    }
                }
            }
        #endif

        if indexPath.section == 0 {
            if isLocalCompany {
                let mySelectedFiscalPeriodAnnually = myFiscalPeriodAnnually[indexPath.row]
                cell.timeLabel.text = mySelectedFiscalPeriodAnnually.time
            } else {
                if let financialTimesAnnually = financialTimesAnnually?[indexPath.row] {
                    cell.timeLabel.text = financialTimesAnnually.time
                }
            }

        } else {
            if isLocalCompany {
                let mySelectedFiscalPeriodQuarterly = myFiscalPeriodQuarterly[indexPath.row]
                cell.timeLabel.text = mySelectedFiscalPeriodQuarterly.time
            } else {
                if let financialTimesQuarterly = financialTimesQuarterly?[indexPath.row] {
                    cell.timeLabel.text = financialTimesQuarterly.time
                }
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isSingle {
            if isLocalCompany {
                company.name = ""
                company.symbol = ""
                company.logoImage = Data()
                fiscalPeriod.time = ""
                fiscalPeriod.period = ""
                FinancialStatement.initializeFinancialStatement()

                if indexPath.section == 0 {
                    let newFiscalTime = myFiscalPeriodAnnually[indexPath.row]
                    fiscalPeriod.time = newFiscalTime.time ?? ""
                    fiscalPeriod.period = newFiscalTime.period ?? ""
                    incomeStatementValues = newFiscalTime.financialStatement?.incomeStatement as! [String: String]
                    balanceSheetStatementValues = newFiscalTime.financialStatement?.balanceSheetStatement as! [String: String]
                    cashFlowStatementValues = newFiscalTime.financialStatement?.cashFlowStatement as! [String: String]
                } else {
                    let newFiscalTime = myFiscalPeriodQuarterly[indexPath.row]
                    fiscalPeriod.time = newFiscalTime.time ?? ""
                    fiscalPeriod.period = newFiscalTime.period ?? ""
                    incomeStatementValues = newFiscalTime.financialStatement?.incomeStatement as! [String: String]
                    balanceSheetStatementValues = newFiscalTime.financialStatement?.balanceSheetStatement as! [String: String]
                    cashFlowStatementValues = newFiscalTime.financialStatement?.cashFlowStatement as! [String: String]
                }
                company.logoImage = myNewCompany?.logoImage ?? Data()
                company.symbol = myNewCompany?.symbol ?? ""
                company.name = myNewCompany?.name ?? ""

                isHomeFetchOnlineData = false
            } else {
                if indexPath.section == 0 {
                    guard let newfinancialTime = financialTimesAnnually?[indexPath.row] else {
                        return
                    }
                    fiscalPeriod = newfinancialTime
                } else {
                    guard let newfinancialTime = financialTimesQuarterly?[indexPath.row] else {
                        return
                    }
                    fiscalPeriod = newfinancialTime
                }
                company = newCompany!
                isHomeFetchOnlineData = true
            }
        } else {
            selectedNumbers += 1
            selectedIndexPaths = tableView.indexPathsForSelectedRows
            #if !targetEnvironment(macCatalyst)
                let cell = tableView.cellForRow(at: indexPath)!
                cell.accessoryType = .checkmark

                if let selectedIndexPaths = selectedIndexPaths, selectedIndexPaths.count == 1 {
                    if selectedIndexPaths[0].section == 0 {
                        tableView.reloadSections(IndexSet(arrayLiteral: 1), with: .automatic)
                    } else {
                        tableView.reloadSections(IndexSet(arrayLiteral: 0), with: .automatic)
                    }
                    return
                }
            #else
                if selectedNumbers == 1 {
                    firstPath = selectedIndexPaths![0]
                    tableView.reloadData()
                    let cell = tableView.cellForRow(at: indexPath)!
                    cell.accessoryType = .checkmark
                    return
                }
            #endif
            if isLocalCompany {
                compareCompany.name = ""
                compareCompany.symbol = ""
                compareCompany.logoImage = Data()
                fiscalPeriod1.time = ""
                fiscalPeriod1.period = ""
                fiscalPeriod2.time = ""
                fiscalPeriod2.period = ""
                FinancialStatement.initializeFinancialStatement()

                // 1

                #if !targetEnvironment(macCatalyst)
                    let indexPath1 = selectedIndexPaths![0]
                #else
                    let indexPath1 = firstPath!
                #endif
                var newFiscalTime1: MyFiscalPeriod
                if indexPath1.section == 0 {
                    newFiscalTime1 = myFiscalPeriodAnnually[indexPath1.row]
                } else {
                    newFiscalTime1 = myFiscalPeriodQuarterly[indexPath1.row]
                }

                // 2
                #if !targetEnvironment(macCatalyst)
                    let indexPath2 = selectedIndexPaths![1]
                #else
                    let indexPath2 = selectedIndexPaths![0]
                #endif
                var newFiscalTime2: MyFiscalPeriod
                if indexPath2.section == 0 {
                    newFiscalTime2 = myFiscalPeriodAnnually[indexPath2.row]
                } else {
                    newFiscalTime2 = myFiscalPeriodQuarterly[indexPath2.row]
                }

                // 1
                fiscalPeriod1.time = newFiscalTime1.time ?? ""
                fiscalPeriod1.period = newFiscalTime1.period ?? ""
                incomeStatementValues1 = newFiscalTime1.financialStatement?.incomeStatement as! [String: String]
                balanceSheetStatementValues1 = newFiscalTime1.financialStatement?.balanceSheetStatement as! [String: String]
                cashFlowStatementValues1 = newFiscalTime1.financialStatement?.cashFlowStatement as! [String: String]

                // 2
                fiscalPeriod2.time = newFiscalTime2.time ?? ""
                fiscalPeriod2.period = newFiscalTime2.period ?? ""
                incomeStatementValues2 = newFiscalTime2.financialStatement?.incomeStatement as! [String: String]
                balanceSheetStatementValues2 = newFiscalTime2.financialStatement?.balanceSheetStatement as! [String: String]
                cashFlowStatementValues2 = newFiscalTime2.financialStatement?.cashFlowStatement as! [String: String]

                compareCompany.logoImage = myNewCompany?.logoImage ?? Data()
                compareCompany.symbol = myNewCompany?.symbol ?? ""
                compareCompany.name = myNewCompany?.name ?? ""

                isCompareFetchOnlineData = false
            } else {
                // 1

                #if !targetEnvironment(macCatalyst)
                    let indexPath1 = selectedIndexPaths![0]
                #else
                    let indexPath1 = firstPath!
                #endif
                if indexPath1.section == 0 {
                    fiscalPeriod1 = financialTimesAnnually![indexPath1.row]
                } else {
                    fiscalPeriod1 = financialTimesQuarterly![indexPath1.row]
                }

                // 2
                #if !targetEnvironment(macCatalyst)
                    let indexPath2 = selectedIndexPaths![1]
                #else
                    let indexPath2 = selectedIndexPaths![0]
                #endif
                if indexPath2.section == 0 {
                    fiscalPeriod2 = financialTimesAnnually![indexPath2.row]
                } else {
                    fiscalPeriod2 = financialTimesQuarterly![indexPath2.row]
                }

                compareCompany = newCompany!
                isCompareFetchOnlineData = true
            }
        }

        delegate?.didSelectedFiscalPeriod()
        navigationController?.popToRootViewController(animated: true)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
        selectedIndexPaths = tableView.indexPathsForSelectedRows
        selectedNumbers -= 1
        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if isLocalCompany {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized) { _, _, _ in

                // delete the company from Core Data
                let context = CoreDataManager.shared.persistentContainer.viewContext

                if indexPath.section == 0 {
                    let myFiscalPeriod = self.myFiscalPeriodAnnually[indexPath.row]
                    self.myFiscalPeriodAnnually.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    context.delete(myFiscalPeriod)
                } else {
                    let myFiscalPeriod = self.myFiscalPeriodQuarterly[indexPath.row]
                    self.myFiscalPeriodQuarterly.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    context.delete(myFiscalPeriod)
                }

                do {
                    try context.save()
                } catch let saveErr {
                    print("Failed to delete company:", saveErr)
                }
            }

            deleteAction.backgroundColor = UIColor.red

            let editAction = UIContextualAction(style: .normal, title: "Edit".localized) { _, _, _ in
                let editFiscalPeriodController = CreateOrEditFiscalPeriodController()

                let navController = FRGNavigationController(rootViewController: editFiscalPeriodController)

                editFiscalPeriodController.delegate = self
                editFiscalPeriodController.indexPath = indexPath
                if indexPath.section == 0 {
                    editFiscalPeriodController.myFiscalPeriod = self.myFiscalPeriodAnnually[indexPath.row]
                } else {
                    editFiscalPeriodController.myFiscalPeriod = self.myFiscalPeriodQuarterly[indexPath.row]
                }

                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            editAction.backgroundColor = UIColor.backgroundColor

            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        } else {
            return nil
        }
    }
}

// MARK: CreateOrEditFiscalPeriodControllerDelegate

extension FiscalPeriodController: CreateOrEditFiscalPeriodControllerDelegate {
    func didEditFiscalPeriod(myFiscalPeriod: MyFiscalPeriod, indexPath: IndexPath) {
        if myFiscalPeriod.period == "Annually" {
            if let row = myFiscalPeriodAnnually.firstIndex(of: myFiscalPeriod) {
                tableView.reloadRows(at: [IndexPath(row: row, section: 0)], with: .middle)
            } else {
                myFiscalPeriodAnnually.append(myFiscalPeriod)
                myFiscalPeriodQuarterly.remove(at: indexPath.row)
                tableView.reloadData()
                let newIndexPath = IndexPath(row: myFiscalPeriodAnnually.count - 1, section: 0)
                tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
        } else {
            if let row = myFiscalPeriodQuarterly.firstIndex(of: myFiscalPeriod) {
                tableView.reloadRows(at: [IndexPath(row: row, section: 1)], with: .middle)
            } else {
                myFiscalPeriodQuarterly.append(myFiscalPeriod)
                myFiscalPeriodAnnually.remove(at: indexPath.row)
                tableView.reloadData()
                let newIndexPath = IndexPath(row: myFiscalPeriodQuarterly.count - 1, section: 1)
                tableView.reloadRows(at: [newIndexPath], with: .automatic)
            }
        }
    }

    func didAddFiscalPeriod(myFiscalPeriod: MyFiscalPeriod) {
        if myFiscalPeriod.period == "Annually" {
            myFiscalPeriodAnnually.append(myFiscalPeriod)
            if let selectedIndexPaths = selectedIndexPaths {
                let selectedIndexPath = selectedIndexPaths[0]
                if selectedIndexPath.section == 1 {
                    return
                }
            }
            let newIndexPath = IndexPath(row: myFiscalPeriodAnnually.count - 1, section: 0)
            tableView.insertRows(at: [newIndexPath], with: .middle)
        } else {
            myFiscalPeriodQuarterly.append(myFiscalPeriod)
            if let selectedIndexPaths = selectedIndexPaths {
                let selectedIndexPath = selectedIndexPaths[0]
                if selectedIndexPath.section == 0 {
                    return
                }
            }
            let newIndexPath = IndexPath(row: myFiscalPeriodQuarterly.count - 1, section: 1)
            tableView.insertRows(at: [newIndexPath], with: .middle)
        }
    }
}

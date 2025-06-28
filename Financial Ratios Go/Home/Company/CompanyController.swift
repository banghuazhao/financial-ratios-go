//
//  CompanyController.swift
//  Finiance Ratio Calculator
//
//  Created by Banghua Zhao on 9/9/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
#endif
import UIKit

class CompanyController: FRGViewController, UIImagePickerControllerDelegate {
    #if !targetEnvironment(macCatalyst)
        lazy var bannerView: GADBannerView = {
            let bannerView = GADBannerView()
            bannerView.adUnitID = Constants.bannerViewAdUnitID
            bannerView.rootViewController = self
            bannerView.load(GADRequest())
            return bannerView
        }()
    #endif

    var previousController: FRGViewController!
    var isSearching = false
    var searchText: String = ""
    var searchCompanies = [Company]()
    var myCompanies = [MyCompany]()
    var searchMyCompanies = [MyCompany]()

    lazy var sourceSegmentControl: UISegmentedControl = {
        var s = UISegmentedControl()
        s = UISegmentedControl(items: ["Online".localized, "Local".localized])
        s.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        s.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .selected)
        s.selectedSegmentIndex = 0
        s.backgroundColor = .financialStatementColor
        for index in 0 ... 1 {
            s.setWidth(100, forSegmentAt: index)
        }
        s.sizeToFit()
        s.addTarget(self, action: #selector(segmentChanged(_:)), for: .valueChanged)
        return s
    }()

    lazy var searchController: UISearchController = {
        let s = UISearchController(searchResultsController: nil)
        s.searchBar.placeholder = "Search company names or codes".localized
        s.obscuresBackgroundDuringPresentation = false
        s.searchBar.sizeToFit()
        s.searchBar.searchBarStyle = .prominent
        s.inputView?.backgroundColor = .financialStatementColor
        if #available(iOS 13.0, *) {
            s.searchBar.setTextField(color: .financialStatementColor)
        } else {
            let searchFieldBackgroundImage = UIImage(color: .financialStatementColor, size: CGSize(width: 44, height: 16))?.withRoundCorners(4)
            UISearchBar.appearance().setSearchFieldBackgroundImage(searchFieldBackgroundImage, for: .normal)
        }
        s.searchBar.delegate = self
        return s
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: companyRowHeight, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        tableView.register(CompanyCell.self, forCellReuseIdentifier: "CompanyCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .backgroundColor

        return tableView
    }()

    lazy var editLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit Local Company".localized
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showEditing))
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(tapGestureRecognizer)
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        definesPresentationContext = true

        setupNav()

        setupView()

        myCompanies = CoreDataManager.shared.fetchLocalCompanies()

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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        navigationController?.setToolbarHidden(true, animated: false)
    }

    private func setupNav() {
        navigationItem.titleView = sourceSegmentControl

        let barItem1 = UIBarButtonItem(image: #imageLiteral(resourceName: "plus"), style: .plain, target: self, action: #selector(addCompany))

        navigationItem.rightBarButtonItem = barItem1

        navigationItem.title = "Companies".localized
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupView() {
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: actions

extension CompanyController {
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        isSearching = false
        searchText = ""
        searchController.searchBar.text = ""
        tableView.reloadData()
        if sender.selectedSegmentIndex == 0 {
            tableView.setEditing(false, animated: false)
        }
    }

    @objc private func addCompany() {
        let addCompanyController = CreateOrEditCompanyController()

        let navController = FRGNavigationController(rootViewController: addCompanyController)

        addCompanyController.delegate = self
        navController.modalPresentationStyle = .fullScreen

        present(navController, animated: true, completion: nil)
    }

    @objc private func showEditing() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            editLabel.text = "Edit Local Company".localized
        } else {
            tableView.setEditing(true, animated: true)
            editLabel.text = "Done".localized
        }
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate

extension CompanyController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isSearching {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                return searchCompanies.count
            } else {
                return searchMyCompanies.count
            }
        } else {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                return companies?.count ?? 0
            } else {
                return myCompanies.count
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return companyRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CompanyCell", for: indexPath) as! CompanyCell

        // Configure the cell...
        if isSearching {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                cell.cellCompany = searchCompanies[indexPath.row]
                cell.myCompany = nil
            } else {
                cell.cellCompany = nil
                cell.myCompany = searchMyCompanies[indexPath.row]
            }
        } else {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                cell.cellCompany = companies?[indexPath.row]
                cell.myCompany = nil
            } else {
                cell.cellCompany = nil
                cell.myCompany = myCompanies[indexPath.row]
            }
        }

        if sourceSegmentControl.selectedSegmentIndex == 0 {
            cell.accessoryType = .detailDisclosureButton
            cell.isUser = false
        } else {
            cell.accessoryType = .disclosureIndicator
            cell.isUser = true
        }
        cell.searchText = searchText
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! CompanyCell
        let imageData = cell.companyIconView.image?.pngData() ?? UIImage(named: "select_photo_empty")!.pngData()!
        let financialTimeTableViewController = FiscalPeriodController()
        if isSearching {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                var newCompany = searchCompanies[indexPath.row]
                newCompany.logoImage = imageData
                financialTimeTableViewController.newCompany = newCompany
                financialTimeTableViewController.isLocalCompany = false
            } else {
                let myNewCompany = searchMyCompanies[indexPath.row]
                myNewCompany.logoImage = imageData
                financialTimeTableViewController.myNewCompany = myNewCompany
                financialTimeTableViewController.isLocalCompany = true
            }
        } else {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                var newCompany = companies?[indexPath.row]
                newCompany?.logoImage = imageData
                financialTimeTableViewController.newCompany = newCompany
                financialTimeTableViewController.isLocalCompany = false
            } else {
                let myNewCompany = myCompanies[indexPath.row]
                myNewCompany.logoImage = imageData
                financialTimeTableViewController.myNewCompany = myNewCompany
                financialTimeTableViewController.isLocalCompany = true
            }
        }
        financialTimeTableViewController.delegate = previousController as? FiscalPeriodControllerDelegate
        navigationController?.pushViewController(financialTimeTableViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "No companies available...".localized
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16)

        if isSearching {
            return label
        } else {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                return label
            } else {
                if myCompanies.count == 0 {
                    return label
                } else {
                    return editLabel
                }
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if isSearching {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                return searchCompanies.count == 0 ? 150 : 0
            } else {
                return searchMyCompanies.count == 0 ? 150 : 0
            }
        } else {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                return companies?.count == 0 ? 150 : 0
            } else {
                return 150
            }
        }
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if sourceSegmentControl.selectedSegmentIndex == 1 && !isSearching {
            let deleteAction = UIContextualAction(style: .destructive, title: "Delete".localized) { _, _, _ in
                let myCompany = self.myCompanies[indexPath.row]

                self.myCompanies.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .none)

                // delete the company from Core Data
                let context = CoreDataManager.shared.persistentContainer.viewContext

                context.delete(myCompany)

                do {
                    try context.save()
                } catch let saveErr {
                    print("Failed to delete company:", saveErr)
                }
                tableView.reloadData()
            }

            deleteAction.backgroundColor = UIColor.red

            let editAction = UIContextualAction(style: .normal, title: "Edit".localized) { _, _, _ in
                let editCompanyController = CreateOrEditCompanyController()

                let navController = FRGNavigationController(rootViewController: editCompanyController)

                editCompanyController.delegate = self
                editCompanyController.myCompany = self.myCompanies[indexPath.row]
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
            editAction.backgroundColor = UIColor.backgroundColor

            return UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        }
        return nil
    }

    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CompanyCell

        let companyProfileController = CompanyProfileController()
        companyProfileController.companyName = cell.companyNameLabel.text
        companyProfileController.symbol = cell.companyCodeLabel.text
        let navigationController = FRGNavigationController(rootViewController: companyProfileController)
        present(navigationController, animated: true, completion: nil)
    }
}

// MARK: - UISearchBarDelegate

extension CompanyController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if searchText != "" {
            if sourceSegmentControl.selectedSegmentIndex == 0 {
                let searchTextLower = searchText.lowercased()

                DispatchQueue.global(qos: .userInitiated).async {
                    if let companies = companies {
                        var temp = companies.filter({ (company) -> Bool in
                            company.name.lowercased().contains(searchTextLower) ||
                                company.symbol.lowercased().contains(searchTextLower)
                        })
                        temp.sort { c1, c2 in
                            let s1 = c1.symbol.lowercased()
                            let s2 = c2.symbol.lowercased()
                            let index1: Int = s1.indexOfSubstring(subString: searchTextLower) ?? 10000
                            let index2: Int = s2.indexOfSubstring(subString: searchTextLower) ?? 10000
                            return index1 < index2
                        }
                        
                        DispatchQueue.main.async {
                            if self.searchText.lowercased() != searchTextLower { return }
                            self.searchCompanies = temp
                            self.isSearching = true
                            self.tableView.reloadData()
                        }
                    }
                }
            } else {
                searchMyCompanies = myCompanies.filter({ (myCompany) -> Bool in
                    myCompany.name!.lowercased().contains(searchText.lowercased()) ||
                        myCompany.symbol!.lowercased().contains(searchText.lowercased())
                })
                isSearching = true
                tableView.reloadData()
            }

        } else {
            isSearching = false
            tableView.reloadData()
        }
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = searchText
        if searchBar.text == "" {
            isSearching = false
            tableView.reloadData()
            let parent = view.superview
            view.removeFromSuperview()
            view = nil
            parent?.addSubview(view)
        }
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        searchText = ""
        searchBar.text = ""
        tableView.reloadData()
        let parent = view.superview
        view.removeFromSuperview()
        view = nil
        parent?.addSubview(view)
    }
}

// MARK: - CreateOrEditCompanyControllerDelegate

extension CompanyController: CreateOrEditCompanyControllerDelegate {
    func didEditCompany(myCompany: MyCompany) {
        let row = myCompanies.firstIndex(of: myCompany)
        let reloadIndexPath = IndexPath(row: row!, section: 0)
        tableView.reloadRows(at: [reloadIndexPath], with: .middle)
    }

    func didCreateCompany(myCompany: MyCompany) {
        sourceSegmentControl.selectedSegmentIndex = 1
        isSearching = false
        searchController.searchBar.text = ""
        tableView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            self.myCompanies.append(myCompany)
            let newIndexPath = IndexPath(row: self.myCompanies.count - 1, section: 0)
            self.tableView.insertRows(at: [newIndexPath], with: .middle)
        }
    }
}

extension CompanyController {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if searchController.searchBar.isFirstResponder {
            searchController.searchBar.resignFirstResponder()
        }
    }
}

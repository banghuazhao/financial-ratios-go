//
//  MenuController.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 10/5/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import MessageUI
import SafariServices
import UIKit

#if !targetEnvironment(macCatalyst)
    import GoogleMobileAds
    import MBProgressHUD
#endif

protocol MenuControllerDelegate {
    func didChangeLanguage()
}

class MenuController: FRGViewController, UIGestureRecognizerDelegate, MFMailComposeViewControllerDelegate {
    var delegate: MenuControllerDelegate?

    let menuModels = MenuModels()

    var panGestureRecognizer: UIPanGestureRecognizer!
    var tapGestureRecognizer: UITapGestureRecognizer!

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: dataRowLeftRightSpace, bottom: 0, right: 0)
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 100))

        tableView.register(MenuCell.self, forCellReuseIdentifier: "MenuCell")

        tableView.delegate = self
        tableView.dataSource = self

        tableView.backgroundColor = .financialStatementColor

        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupView()
    }

    private func setupNav() {
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
        panGestureRecognizer = UIPanGestureRecognizer(
            target: self,
            action: #selector(wasDragged))
        panGestureRecognizer.delegate = self
        navigationController?.view.addGestureRecognizer(panGestureRecognizer)
        navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.backgroundColor = .navBarColor
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: isIphone ? 26 : 32, weight: .bold),
            ]

            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.compactAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        } else {
            navigationController?.navigationBar.backgroundColor = .navBarColor
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
            navigationController?.navigationBar.largeTitleTextAttributes = [
                .foregroundColor: UIColor.white,
                .font: UIFont.systemFont(ofSize: isIphone ? 26 : 32, weight: .bold),
            ]
        }
    }

    private func setupView() {
        screenTapGesture.addTarget(self, action: #selector(selfDismiss))
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource

extension MenuController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuModels.models.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return menuRowHeight
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuCell") as! MenuCell

        cell.menuModel = menuModels.models[indexPath.row]

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        #if !targetEnvironment(macCatalyst)
            if indexPath.row == 0 {
                navigationController?.pushViewController(AboutController(), animated: true)
            }

            if indexPath.row == 1 {
                navigationController?.pushViewController(RemoveAdsViewController(), animated: true)
            }

            if indexPath.row == 2 {
                let ac = UIAlertController(title: "Change language".localized, message: "Select a language".localized, preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "English", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("en", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "简体中文", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "繁體中文", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("zh-Hant", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "日本語", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("ja", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))

                if let cell = tableView.cellForRow(at: indexPath) {
                    ac.popoverPresentationController?.sourceView = cell
                    ac.popoverPresentationController?.sourceRect = cell.bounds
                }

                present(ac, animated: true, completion: nil)
            }

            if indexPath.row == 3 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                let alterController = UIAlertController(title: "Clear Cache".localized, message: "Do you want to clear cache (statment cache, company logo cache and piscal period cache)".localized + " (\(getCacheDirectorySize()))", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Yes".localized, style: .default) { _ in
                    clearCacheOfLocal()
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                let action2 = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
                alterController.addAction(action1)
                alterController.addAction(action2)
                present(alterController, animated: true)
            }

            if indexPath.row == 4 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                navigationController?.pushViewController(FeedbackViewController(), animated: true)
            }

            if indexPath.row == 5 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                if let reviewURL = URL(string: "https://itunes.apple.com/app/id\(Constants.finanicalRatiosGoIOSAppID)?action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                }
            }

            if indexPath.row == 6 {
                let textToShare = "Financial Ratios Go".localized

                let image = UIImage(named: "appIcon128")!

                guard let url = URL(string: "http://itunes.apple.com/app/id\(Constants.finanicalRatiosGoIOSAppID)") else {
                    return
                }

                let objectsToShare = [textToShare, url, image] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
                    popoverController.sourceView = tableView.cellForRow(at: indexPath)
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                present(activityVC, animated: true, completion: nil)
            }

            if indexPath.row == 7 {
                navigationController?.pushViewController(MoreAppsViewController(), animated: true)
            }
        #else
            if indexPath.row == 0 {
                navigationController?.pushViewController(AboutController(), animated: true)
            }

            if indexPath.row == 1 {
                let ac = UIAlertController(title: "Change language".localized, message: "Select a language".localized, preferredStyle: .actionSheet)
                ac.addAction(UIAlertAction(title: "English", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("en", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "简体中文", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("zh-Hans", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "繁體中文", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("zh-Hant", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "日本語", style: .default, handler: { [weak self] _ in
                    guard let self = self else { return }
                    UserDefaults.standard.set("ja", forKey: "i18n_language")
                    self.navigationController?.navigationBar.topItem?.title = "Financial Ratios Go".localized
                    self.tableView.reloadData()
                    self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "Back".localized, style: .plain, target: nil, action: nil)
                    self.delegate?.didChangeLanguage()
                }))

                ac.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil))

                if let cell = tableView.cellForRow(at: indexPath) {
                    ac.popoverPresentationController?.sourceView = cell
                    ac.popoverPresentationController?.sourceRect = cell.bounds
                }

                present(ac, animated: true, completion: nil)
            }

            if indexPath.row == 2 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                let alterController = UIAlertController(title: "Clear Cache".localized, message: "Do you want to clear cache (statment cache, company logo cache and piscal period cache)".localized + " (\(getCacheDirectorySize()))", preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Yes".localized, style: .default) { _ in
                    clearCacheOfLocal()
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
                let action2 = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
                alterController.addAction(action1)
                alterController.addAction(action2)
                present(alterController, animated: true)
            }

            if indexPath.row == 3 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                navigationController?.pushViewController(FeedbackViewController(), animated: true)
            }

            if indexPath.row == 4 {
                tableView.cellForRow(at: indexPath)?.setSelected(false, animated: true)
                if let reviewURL = URL(string: "https://itunes.apple.com/app/id\(Constants.finanicalRatiosGoMacOSAppID)?action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                }
            }

            if indexPath.row == 5 {
                let textToShare = "Financial Ratios Go".localized

                let image = UIImage(named: "appIcon128")!

                guard let url = URL(string: "http://itunes.apple.com/app/id\(Constants.finanicalRatiosGoMacOSAppID)") else {
                    return
                }

                let objectsToShare = [textToShare, url, image] as [Any]
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)

                if let popoverController = activityVC.popoverPresentationController {
                    popoverController.sourceRect = tableView.cellForRow(at: indexPath)?.bounds ?? .zero
                    popoverController.sourceView = tableView.cellForRow(at: indexPath)
                    popoverController.permittedArrowDirections = UIPopoverArrowDirection(rawValue: 0)
                }
                present(activityVC, animated: true, completion: nil)
            }

            if indexPath.row == 6 {
                navigationController?.pushViewController(MoreAppsViewController(), animated: true)
            }
        #endif
    }
}

extension MenuController {
    // MARK: Swipe to dismiss viewController:

    /*
     - Make UIPanGestureRecognizer
     - In the action method call:
     swipeToDismiss(_ viewToAnimate: UIView, _ panGesture: UIPanGestureRecognizer)
     */

    private var ANIMATION_DURATION: Double { return 0.2 }

    private var MAX_VELOCITY_x: CGFloat {
        return view.bounds.width * 0.2
    }

    private var originLeft: CGPoint {
        return CGPoint(
            x: -view.frame.size.width,
            y: -view.frame.origin.y)
    }

    fileprivate func animateToDismiss(_ viewToDismiss: UIView, to origin: CGPoint) {
        UIView.animate(withDuration: ANIMATION_DURATION, animations: {
            viewToDismiss.frame.origin = origin
        }, completion: { isCompleted in
            if isCompleted {
                self.dismiss(animated: false, completion: nil)
            }
        })
    }

    fileprivate func setBackground(alpha: CGFloat) {
        for view in view.subviews {
            if view is UIVisualEffectView {
                UIView.animate(withDuration: ANIMATION_DURATION, animations: {
                    view.alpha = alpha
                })
            }
        }
    }

    func swipeToDismiss(_ viewToAnimate: UIView, _ panGesture: UIPanGestureRecognizer) {
        let velocity = panGesture.velocity(in: view)

        let swipeLeft = velocity.x < -MAX_VELOCITY_x || viewToAnimate.frame.origin.x < -view.bounds.width * 0.4

        let translation = panGesture.translation(in: view)

        if panGesture.state == .changed {
            if translation.x < 0 {
                setBackground(alpha: 0)
                viewToAnimate.frame.origin.x = translation.x
            }
            // viewToAnimate.frame.origin = CGPoint(x: translation.x, y: translation.y)
        } else if panGesture.state == .ended {
            if swipeLeft {
                animateToDismiss(viewToAnimate, to: originLeft)
            } else {
                setBackground(alpha: 1)
                UIView.animate(withDuration: ANIMATION_DURATION, animations: {
                    viewToAnimate.frame.origin.x = 0
                })
            }
        }
    }
}

// MARK: - actions

extension MenuController {
    @objc func wasDragged(gestureRecognizer: UIPanGestureRecognizer) {
        swipeToDismiss((navigationController?.view)!, panGestureRecognizer)
    }

    @objc func selfDismiss() {
        let touchPoint = screenTapGesture.location(in: tableView)
        if touchPoint.x > UIScreen.main.bounds.width * 0.8 {
            dismiss(animated: true, completion: nil)
        }
    }
}

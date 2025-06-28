//
//  MoreAppsViewController.swift
//  Financial Ratios Go
//
//  Created by Banghua Zhao on 1/2/21.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import UIKit

class MoreAppsViewController: UIViewController {
    #if !targetEnvironment(macCatalyst)
        let appItems = [
            AppItem(
                title: "Finance Go".localized,
                detail: "Financial Reports & Investing".localized,
                icon: UIImage(named: "appIcon_finance_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.financeGoAppID)")),
            AppItem(
                title: "Sudoku Lover".localized,
                detail: "Sudoku Lover".localized,
                icon: UIImage(named: "sudoku_lover"),
                url: URL(string: "http://itunes.apple.com/app/id1620749798")),
            AppItem(
                title: "Money Tracker".localized,
                detail: "Budget, Expense & Bill Planner".localized,
                icon: UIImage(named: "appIcon_money_tracker"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.moneyTrackerAppID)")),
            AppItem(
                title: "BMI Diary".localized,
                detail: "Fitness, Weight Loss &Health".localized,
                icon: UIImage(named: "appIcon_bmiDiary"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.BMIDiaryAppID)")),
            AppItem(
                title: "Relaxing Up".localized,
                detail: "Meditation&Healing".localized,
                icon: UIImage(named: "relaxing_up"),
                url: URL(string: "http://itunes.apple.com/app/id1618712178")),
            AppItem(
                title: "Image Guru".localized,
                detail: "Photo Editor,Filter".localized,
                icon: UIImage(named: "image_guru"),
                url: URL(string: "http://itunes.apple.com/app/id1625021625")),
            AppItem(
                title: "Mint Translate".localized,
                detail: "Text Translator".localized,
                icon: UIImage(named: "mint_translate"),
                url: URL(string: "http://itunes.apple.com/app/id1638456603")),
            AppItem(
                title: "Shows".localized,
                detail: "Guide for Movie&TV Shows".localized,
                icon: UIImage(named: "shows"),
                url: URL(string: "http://itunes.apple.com/app/id1624910011")),
            AppItem(
                title: "Yes Habit".localized,
                detail: "Habit Tracker".localized,
                icon: UIImage(named: "yes_habit"),
                url: URL(string: "http://itunes.apple.com/app/id1637643734")),
            AppItem(
                title: "We Play Piano".localized,
                detail: "Piano Keyboard".localized,
                icon: UIImage(named: "we_play_piano"),
                url: URL(string: "http://itunes.apple.com/app/id1625018611")),
            AppItem(
                title: "Instant Face".localized,
                detail: "Avatar Maker".localized,
                icon: UIImage(named: "instant_face"),
                url: URL(string: "http://itunes.apple.com/app/id1638563222")),
            AppItem(
                title: "World Weather Live".localized,
                detail: "All Cities".localized,
                icon: UIImage(named: "world_weather_live"),
                url: URL(string: "http://itunes.apple.com/app/id1612773646")),
            AppItem(
                title: "Water Tracker".localized,
                detail: "Drink Water Log".localized,
                icon: UIImage(named: "water_tracker"),
                url: URL(string: "http://itunes.apple.com/app/id1534891702")),
            AppItem(
                title: "More Apps".localized,
                detail: "Check out more Apps made by us".localized,
                icon: UIImage(named: "appIcon_appStore"),
                url: URL(string: "https://apps.apple.com/us/developer/%E7%92%90%E7%92%98-%E6%9D%A8/id1599035519")),
        ]
    #else
        let appItems = [
            AppItem(
                title: "Financial Ratios Go (iOS App)".localized,
                detail: "Finance, Ratios, Investing".localized,
                icon: UIImage(named: "appIcon128"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.finanicalRatiosGoIOSAppID)")),
            AppItem(
                title: "Finance Go".localized,
                detail: "Financial Reports & Investing".localized,
                icon: UIImage(named: "appIcon_finance_go"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.financeGoAppID)")),
            AppItem(
                title: "Money Tracker".localized,
                detail: "Budget, Expense & Bill Planner".localized,
                icon: UIImage(named: "appIcon_money_tracker"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.moneyTrackerAppID)")),
            AppItem(
                title: "BMI Diary".localized,
                detail: "Fitness, Weight Loss &Health".localized,
                icon: UIImage(named: "appIcon_bmiDiary"),
                url: URL(string: "http://itunes.apple.com/app/id\(Constants.BMIDiaryAppID)")),
            AppItem(
                title: "More Apps".localized,
                detail: "Check out more Apps made by us".localized,
                icon: UIImage(named: "appIcon_appStore"),
                url: URL(string: "https://apps.apple.com/us/developer/%E7%92%90%E7%92%98-%E6%9D%A8/id1599035519")),
        ]
    #endif

    #if !targetEnvironment(macCatalyst)
        lazy var tableView: UITableView = {
            let tv = UITableView()
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.dataSource = self
            tv.register(AppItemCell.self, forCellReuseIdentifier: "AppItemCell")
            tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 80))
            return tv
        }()
    #else
        lazy var tableView = UITableView(frame: .zero, style: .grouped).then { tv in
            tv.backgroundColor = .clear
            tv.delegate = self
            tv.dataSource = self
            tv.register(AppItemCell.self, forCellReuseIdentifier: "AppItemCell")
            tv.register(MoreAppsHeaderCell.self, forHeaderFooterViewReuseIdentifier: "MoreAppsHeaderCell")
            tv.separatorStyle = .none
        }
    #endif

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .financialStatementColor
        title = "More Apps".localized
        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}

extension MoreAppsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return appItems.count
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 + 16 + 16
    }

    #if targetEnvironment(macCatalyst)
        func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MoreAppsHeaderCell") as! MoreAppsHeaderCell
            return header
        }
    #endif

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AppItemCell", for: indexPath) as! AppItemCell
        cell.appItem = appItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appItem = appItems[indexPath.row]
        if let url = appItem.url, UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

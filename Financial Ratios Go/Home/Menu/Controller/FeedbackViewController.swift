//
//  FeedbackViewController.swift
//  Financial Statements Go
//
//  Created by Banghua Zhao on 2021/1/16.
//  Copyright © 2021 Banghua Zhao. All rights reserved.
//

import MessageUI
import SnapKit
import Then
import UIKit

class FeedbackViewController: UIViewController {
    var feedbackItems = [FeedbackItem]()

    lazy var tableView = UITableView().then { tv in
        tv.delegate = self
        tv.dataSource = self
        tv.register(FeedbackItemCell.self, forCellReuseIdentifier: "FeedbackItemCell")
        tv.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tv.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 80))
        tv.backgroundColor = .clear
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        title = "Feedback".localized
        view.backgroundColor = .financialStatementColor

        if let regionCode = Locale.current.regionCode, regionCode == "CN" {
            feedbackItems = [
                FeedbackItem(
                    title: "WeChat Official Account".localized,
                    detail: "Send a message to Apps Bay official account".localized,
                    icon: UIImage(named: "icon_wechat")),
                FeedbackItem(
                    title: "Email".localized,
                    detail: "Write an email to appsbay@qq.com".localized,
                    icon: UIImage(named: "icon_email")),
            ]
        } else {
            feedbackItems = [
                FeedbackItem(
                    title: "Facebook Page".localized,
                    detail: "Send a message to Apps Bay Facebook page".localized,
                    icon: UIImage(named: "icon_facebook")),

                FeedbackItem(
                    title: "Email".localized,
                    detail: "Write an email to appsbayarea@gmail.com".localized,
                    icon: UIImage(named: "icon_email")),
            ]
        }

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.bottom.left.right.top.equalToSuperview()
        }
    }
}

extension FeedbackViewController {
    @objc func backToHome() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension FeedbackViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedbackItems.count
    }

//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 50 + 16 + 16
//    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackItemCell", for: indexPath) as! FeedbackItemCell
        cell.feedbackItem = feedbackItems[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let regionCode = Locale.current.regionCode, regionCode == "CN" {
            if indexPath.row == 0 {
                let alterController = UIAlertController(title: "Send a message to WeChat official account".localized, message: "Please search \"Apps Bay\" in WeChat official account. Then leave a message after following the account. Thanks!".localized, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ok".localized, style: .cancel, handler: nil)
                alterController.addAction(action)
                present(alterController, animated: true)
            }
            if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["appsbay@qq.com"])
                    mail.setSubject("\("Countdown Days".localized) - \("Feedback".localized)")
                    present(mail, animated: true)
                }
            }
        } else {
            if indexPath.row == 0 {
                let facebookAppURL = URL(string: "fb://profile/\(Constants.facebookPageID)")!
                if UIApplication.shared.canOpenURL(facebookAppURL) {
                    UIApplication.shared.open(facebookAppURL)
                } else {
                    UIApplication.shared.open(URL(string: "https://www.facebook.com/Apps-Bay-104357371640600")!)
                }
            }
            if indexPath.row == 1 {
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients(["appsbayarea@gmail.com"])
                    mail.setSubject("\("Countdown Days".localized) - \("Feedback".localized)")
                    present(mail, animated: true)
                }
            }
        }
    }
}

// MARK: - MFMailComposeViewControllerDelegate

extension FeedbackViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true) {
            if result == .sent {
                let ac = UIAlertController(title: "Thanks for Your Feedback".localized, message: "We will constantly optimize and maintain our App and make sure users have the best experience".localized, preferredStyle: .alert)
                let action1 = UIAlertAction(title: "Cancel".localized, style: .cancel, handler: nil)
                ac.addAction(action1)
                self.present(ac, animated: true)
            }
        }
    }
}

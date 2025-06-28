//
//  ExplainPopovers.swift
//  SwiftComp
//
//  Created by Banghua Zhao on 3/26/19.
//  Copyright © 2019 Banghua Zhao. All rights reserved.
//

import SafariServices
import SnapKit
import UIKit

class PopupWindow: UIViewController {
    lazy var popupWindow: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

//    var popupWindowWidthConstraint: Constraint!

    lazy var contentView: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = sectionTitleFont
        label.textAlignment = .center
        return label
    }()

    lazy var messageTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.font = dataRowTextFont
        textView.dataDetectorTypes = .all
        textView.textContainer.lineFragmentPadding = .zero
        textView.delegate = self
        return textView
    }()

    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.alpha = 0
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        view.addSubview(popupWindow)

        var popupWindowWidth: CGFloat = UIScreen.main.bounds.width - 40
        if popupWindowWidth < 310 {
            popupWindowWidth = 310
        } else if popupWindowWidth > 500 {
            popupWindowWidth = 500
        }

        popupWindow.snp.makeConstraints { make in
            make.centerX.centerY.equalToSuperview()
            make.width.equalTo(popupWindowWidth)
        }

        popupWindow.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(25)
        }

        contentView.addSubview(titleLabel)
        contentView.addSubview(messageTextView)

        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView)
            make.left.right.equalTo(contentView)
        }

        messageTextView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.bottom.equalTo(contentView)
        }

        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 1
        }, completion: nil)
    }

    deinit {
        print("deinit: PopupWindow")
    }

    @objc func handleDismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.view.alpha = 0
        }, completion: { _ in
            self.dismiss(animated: false, completion: nil)
        })
    }

    func setContent(title: String, message: String) {
        titleLabel.text = title
        messageTextView.text = message
    }
}

extension PopupWindow: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        let safariVC = SFSafariViewController(url: URL)
        present(safariVC, animated: true, completion: nil)
        return false
    }
}

extension PopupWindow: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touch.view == view {
            return true
        }
        return false
    }
}

extension PopupWindow {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        var popupWindowWidth: CGFloat = UIScreen.main.bounds.width - 40
        if popupWindowWidth < 310 {
            popupWindowWidth = 310
        } else if popupWindowWidth > 500 {
            popupWindowWidth = 500
        }

        popupWindow.snp.removeConstraints()
        popupWindow.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(popupWindowWidth)
        }
        if UIDevice.current.orientation.isLandscape {
            print("Landscape")

            // MARK: TO DO

        } else {
            print("Portrait")
        }
    }
}

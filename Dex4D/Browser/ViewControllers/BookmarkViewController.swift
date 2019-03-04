//
//  BrowserCollectViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/23.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

enum BookmarkType: Int {
    case bookmark
    case history
}

class BookmarkViewController: BaseViewController {
    
    weak var presentViewController: UIViewController?
    
    let viewModel = BookmarkViewModel()
    
    private lazy var bookmarkController: BookmarkTableViewController = {
        let vc = BookmarkTableViewController(type: .bookmark)
        vc.delegate = self
        return vc
    }()
    
    private lazy var historyController: BookmarkTableViewController = {
        let vc = BookmarkTableViewController(type: .history)
        vc.delegate = self
        return vc
    }()
    
    var collectType: BookmarkType = .bookmark {
        didSet {
            switch collectType {
            case .bookmark:
                bookmarkController.view.isHidden = false
                historyController.view.isHidden = true
                break
            case .history:
                bookmarkController.view.isHidden = true
                historyController.view.isHidden = false
                break
            }
        }
    }
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
//        button.setTitle(viewModel.editButtonText, for: .normal)
        button.setImage(R.image.icon_delete(), for: .normal)
        button.addTarget(self, action: #selector(editAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var totalButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(viewModel.totalButtonText, for: .normal)
        button.addTarget(self, action: #selector(totalAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(viewModel.cancelButtonText, for: .normal)
        button.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "343442")
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(viewModel.deleteButtonText, for: .normal)
        button.addTarget(self, action: #selector(deleteAction), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var segmented: UISegmentedControl = {
        let items = ["BookMark".localized, "History".localized]
        let segmented = UISegmentedControl(items: items)
        segmented.frame = CGRect(x: 0, y: 0, width: 200, height: 0)
        segmented.selectedSegmentIndex = 0
        segmented.tintColor = Colors.globalColor
        segmented.addTarget(self, action: #selector(self.segmentAction(segmented:)), for: UIControlEvents.valueChanged)
        
        let dic: NSDictionary = [NSAttributedStringKey.foregroundColor: Colors.globalColor, NSAttributedStringKey.font: UIFont.defaultFont(size: 14)];
        segmented.setTitleTextAttributes(dic as? [AnyHashable : Any], for: UIControlState.normal)
        let dic2: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont.defaultFont(size: 16)];
        segmented.setTitleTextAttributes(dic2 as? [AnyHashable : Any], for: UIControlState.selected)
        return segmented
    }()
    
    override func setBackButton() {
        navigationBar.setBackButton(target: self, action: #selector(self.returnAction))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleView = segmented
        navigationBar.rightBarButton = editButton
        
        view.addSubview(historyController.view)
        historyController.view.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        view.addSubview(bookmarkController.view)
        bookmarkController.view.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(-Constants.BottomBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(49)
        }
        checkDataSource()
    }
    
    @objc func returnAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentAction(segmented: UISegmentedControl) {
        collectType = BookmarkType(rawValue: segmented.selectedSegmentIndex)!
        checkDataSource()
        if bookmarkController.canEdit {
            cancelAction()
        }
        if historyController.canEdit {
            cancelAction()
        }
    }
    
    @objc func editAction() {
        deleteButton.isHidden = false
        navigationBar.leftBarButton = cancelButton
        navigationBar.rightBarButton = totalButton
        switch collectType {
        case .bookmark:
            bookmarkController.edit()
            break
        case .history:
            historyController.edit()
            break
        }
    }
    
    @objc func totalAction() {
        switch collectType {
        case .bookmark:
            bookmarkController.selectAll()
            break
        case .history:
            historyController.selectAll()
            break
        }
    }
    
    @objc func cancelAction() {
        deleteButton.isHidden = true
        setBackButton()
        navigationBar.rightBarButton = editButton
        switch collectType {
        case .bookmark:
            bookmarkController.cancel()
            break
        case .history:
            historyController.cancel()
            break
        }
    }
    
    @objc func deleteAction() {
        switch collectType {
        case .bookmark:
            bookmarkController.delete()
            break
        case .history:
            historyController.delete()
            break
        }
        cancelAction()
        checkDataSource()
    }
    
    private func checkDataSource() {
        switch  collectType {
        case .bookmark:
            editButton.isHidden = BookmarkStorage.shared.bookmarks.isEmpty
            break
        case .history:
            editButton.isHidden = BookmarkStorage.shared.histories.isEmpty
            break
        }
    }
    
}

extension BookmarkViewController: BookmarkTableViewDelegate {
    func didSelectRowAt(urlString: String) {
        if let vc = self.presentViewController as? BrowserViewController {
            vc.startRequest(string: urlString)
            returnAction()
        }
    }
}

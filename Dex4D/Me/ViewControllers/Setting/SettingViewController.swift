//
//  SettingViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol SettingViewControllerDelegate: class {
    func pushToLanguage()
    func pushToSecurity()
}

class SettingViewController: BaseTableViewController {
    
    weak var delegate: SettingViewControllerDelegate?
    
    let viewModel = SettingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.title
        dataSource = viewModel.dataSource
    }
    
    @objc private func pushToLanguage() {
        delegate?.pushToLanguage()
    }
    
    @objc private func pushToSecurity() {
        delegate?.pushToSecurity()
    }
    
    @objc private func clearBrowserCache() {
        ClearCacheManage.clearBrowserCache()
        showTipsMessage(message: "Clear success".localized)
        dataSource = viewModel.dataSource
        tableView.reloadData()
    }
    
    @objc private func clearCache() {
        ClearCacheManage.clearAllCache()
        showTipsMessage(message: "Clear success".localized)
        dataSource = viewModel.dataSource
        tableView.reloadData()
    }
    
}

extension MeCoordinator: SettingViewControllerDelegate {
    func pushToLanguage() {
        let vc = ChangeLanguageViewController()
        navigationController.pushViewController(vc, animated: true)
    }
    func pushToSecurity() {
        let vc = SecurityViewController(account: account)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}


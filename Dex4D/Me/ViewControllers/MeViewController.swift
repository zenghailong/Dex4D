//
//  MineViewController.swift
//  TradingPlatform
//
//  Created by ColdChains on 2018/8/16.
//  Copyright © 2018 冰凉的枷锁. All rights reserved.
//

import UIKit

protocol MeViewControllerDelegate: class {
    func pushToSetting()
    func pushToAuthority()
}

class MeViewController: BaseTableViewController {
    
    weak var delegate: MeViewControllerDelegate?
    
    let viewModel = MeViewModel()
    
    let keystore: Keystore
    let account: WalletInfo

    init(keystore: Keystore, account: WalletInfo) {
        self.keystore = keystore
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
    }
    
    
    @objc private func pushToSetting() {
        delegate?.pushToSetting()
    }
    
    @objc private func pushToAuthority() {
        delegate?.pushToAuthority()
    }
    
    @objc private func pushToBrowser() {
        let vc = ClearCacheViewController()
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
        
}

extension MeViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.dataSource.count
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.dataSource[section].count
    }
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CommonTableViewCell.self)) as! CommonTableViewCell
        cell.setupData(style: .common, model: viewModel.dataSource[indexPath.section][indexPath.row])
        return cell
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if let vc = swiftClassFromString(className: viewModel.dataSource[indexPath.section][indexPath.row].push) {
            navigationController?.pushViewController(vc, animated: true)
        }
        if let action = viewModel.dataSource[indexPath.section][indexPath.row].action {
            if self.responds(to: Selector(action)) {
                let control: UIControl = UIControl()
                control.sendAction(Selector(action), to: self, for: nil)
            }
        }
    }
}

extension MeCoordinator: MeViewControllerDelegate {
    func pushToSetting() {
        let vc = SettingViewController()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    func pushToAuthority() {
        let vc = AuthorityViewController(account: account)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}


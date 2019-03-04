//
//  AuthorityViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol AuthorityViewControllerDelegate: class {
    func pushToAuthorityPay(account: WalletInfo, operation: AuthorityOperation.Operation)
}

class AuthorityViewController: BaseTableViewController {
    
    weak var delegate: AuthorityViewControllerDelegate?
    
    let viewModel: AuthorityViewModel
    let account: WalletInfo
    
    init(account: WalletInfo) {
        self.account = account
        self.viewModel = AuthorityViewModel(account: account)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.title
        dataSource = viewModel.dataSource
    }
    
    @objc private func pushToReferral() {
        delegate?.pushToAuthorityPay(account: account, operation: .referral)
    }
    
    @objc private func pushToSwap() {
        delegate?.pushToAuthorityPay(account: account, operation: .swap)
    }

}


extension MeCoordinator: AuthorityViewControllerDelegate {
    func pushToAuthorityPay(account: WalletInfo, operation: AuthorityOperation.Operation) {
        let vc = AuthorityPayViewController(
            account: account,
            operation: operation,
            tokensStorage: tokensStorage
        )
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

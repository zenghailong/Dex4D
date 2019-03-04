//
//  SecurityViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol SecurityViewControllerDelegate: class {
    func pushToKeystore()
}

class SecurityViewController: BaseTableViewController {
    
    var delegate: SecurityViewControllerDelegate?
    
    let viewModel: SecurityViewModel
    let account: WalletInfo
    
    init(account: WalletInfo) {
        self.account = account
        viewModel = SecurityViewModel(account: account)
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
    
    @objc private func pushToMemoric() {
        let coordinator = CreatePINCoordinator(
            navigationController: self.navigationController as! NavigationController,
            enterType: .created,
            type: .memoric
        )
        coordinator.delegate = self
        coordinator.start()
    }
    
    @objc private func pushToKeystore() {
        let coordinator = CreatePINCoordinator(
            navigationController: self.navigationController as! NavigationController,
            enterType: .created,
            type: .keystore
        )
        coordinator.delegate = self
        coordinator.start()
    }

}

extension SecurityViewController: CreatePINCoordinatorDelegate {
    func createPinDone(for enterType: EnterType, coordinator: CreatePINCoordinator) {
        
    }
    func didCancel(in coordinator: CreatePINCoordinator) {
        
    }
    func didVerifyPassword(coordinator: Coordinator, type: GeneratePasswordType) {
        if type == .memoric {
            guard let wallet = WalletManager.shared.currentWallet else {
                return
            }
            WalletManager.shared.keystore.exportMnemonic(wallet: wallet) { (result) in
                switch result {
                case .success(let words):
                    let vc = PassphraseViewController(account: wallet, words: words, option: .read)
                    vc.delegate = self
                    self.navigationController?.pushViewController(vc, animated: true)
                    return
                case .failure(let error):
                    print(error)
                    self.showTipsMessage(message: "Export error".localized)
                }
            }
        } else if type == .keystore {
            delegate?.pushToKeystore()
        }
    }
}

extension MeCoordinator: SecurityViewControllerDelegate {
    func pushToKeystore() {
        let vc = KeystorePasswordViewController()
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MeCoordinator: KeystorePasswordViewControllerDelegate {
    func pushToKeystore(password: String) {
        let vc = KeystoreViewController(password: password, keystore: keystore, account: account)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension SecurityViewController: PassphraseViewControllerDelegate {
    func didPressedContinueButton(account: Wallet, words: [String], in viewController: PassphraseViewController) {
        navigationController?.popViewController(animated: true)
    }
    func didSkipToBackupPhrase(account: Wallet, in viewController: PassphraseViewController) {
        
    }
    func didCancel(in viewController: PassphraseViewController) {
        
    }
}


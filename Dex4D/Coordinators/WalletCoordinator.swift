//
//  WalletCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/28.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import Result

protocol WalletCoordinatorDelegate: class {
    func didFinish(with account: WalletInfo, enterType: EnterType, in coordinator: WalletCoordinator)
    func didCancel(in coordinator: WalletCoordinator)
}

final class WalletCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    var controller: ImportWalletViewController?
    
    weak var delegate: WalletCoordinatorDelegate?
    let navigationController: NavigationController
    let keystore: Keystore
    let enterType: EnterType
    
    init(
        enterType: EnterType,
        keystore: Keystore,
        navigationController: NavigationController = NavigationController()
    ) {
        self.enterType = enterType
        self.keystore = keystore
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: true)
    }
    
    func start() {
        switch enterType {
        case .imported:
            importMainWallet()
        case .created:
            createInstantWallet()
        default :
            break
        }
    }
    
    private func createInstantWallet() {
        navigationController.topViewController?.displayLoading(text: "Create Wallet...".localized, animated: false)
        let password = PasswordGenerator.generateRandom()
        keystore.createAccount(with: password) { result in
            switch result {
            case .success(let account):
                self.keystore.exportMnemonic(wallet: account) { mnemonicResult in
                    self.navigationController.topViewController?.hideLoading(animated: false)
                    switch mnemonicResult {
                    case .success(let words):
                        self.pushBackup(for: account, words: words)
                    case .failure(_):
                        self.navigationController.showTipsMessage(message: "Create Wallet failed".localized)
                    }
                }
            case .failure(_):
                self.navigationController.topViewController?.hideLoading(animated: false)
                self.navigationController.showTipsMessage(message: "Create Wallet failed".localized)
            }
        }
    }
    
    private func importMainWallet() {
        controller = ImportWalletViewController()
        controller?.delegate = self
        navigationController.pushViewController(controller!, animated: true)
    }
    
    func pushBackup(for account: Wallet, words: [String]) {
        let passphraseController = PassphraseViewController(account: account, words: words, option: .first)
        passphraseController.delegate = self
        navigationController.pushViewController(passphraseController, animated: true)
    }
    
    func walletCreated(wallet: WalletInfo) {
        delegate?.didFinish(with: wallet, enterType: enterType, in: self)
    }
}

extension WalletCoordinator: ImportWalletViewControllerDelegate {
    func importWallet(with importSelectType: ImportSelectionType, viewController: ImportWalletViewController) {
        switch importSelectType {
        case .keystore:
            let importKeystoreController = ImportKeystoreController(keystore: keystore, viewModel: ImportKeystoreViewModel())
            importKeystoreController.delegate = self
            viewController.navigationController?.pushViewController(importKeystoreController, animated: true)
        case .mnemonic:
            let importMnemonicController = ImportMnemonicController(keystore: keystore, viewModel: ImportMnemonicViewModel())
            importMnemonicController.delegate = self
            viewController.navigationController?.pushViewController(importMnemonicController, animated: true)
        }
    }
    func didCancelImportWallet(in viewController: ImportWalletViewController) {
        delegate?.didCancel(in: self)
    }
}

extension WalletCoordinator: PassphraseViewControllerDelegate {
    func didCancel(in viewController: PassphraseViewController) {
        delegate?.didCancel(in: self)
    }
    func didPressedContinueButton(account: Wallet, words: [String], in viewController: PassphraseViewController) {
        let enterPhraseController = EnterPhraseViewController(account: account, words: words)
        enterPhraseController.delegate = self
        viewController.navigationController?.pushViewController(enterPhraseController, animated: true)
    }
    func didSkipToBackupPhrase(account: Wallet, in viewController: PassphraseViewController) {
        delegate?.didFinish(with: WalletInfo(type: .hd(account)), enterType: enterType, in: self)
    }
}

extension WalletCoordinator: EnterPhraseViewControllerDelegate {
    func didFinishedBackupPhrase(account: Wallet, in viewController: EnterPhraseViewController) {
        delegate?.didFinish(with: WalletInfo(type: .hd(account)), enterType: enterType, in: self)
    }
}

extension WalletCoordinator: ImportKeystoreControllerDelegate {
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportKeystoreController) {
        keystore.store(object: account.info, fields: fields)
        walletCreated(wallet: account)
    }
}

extension WalletCoordinator: ImportMnemonicControllerDelegate {
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportMnemonicController) {
        keystore.store(object: account.info, fields: fields)
        walletCreated(wallet: account)
    }
}

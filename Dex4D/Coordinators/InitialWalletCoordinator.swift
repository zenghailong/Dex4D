//
//  InitialWalletCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol InitialWalletCoordinatorDelegate: class {
    func didCancel(in coordinator: InitialWalletCoordinator)
    func didAddAccount(_ account: WalletInfo, in coordinator: InitialWalletCoordinator)
}

final class InitialWalletCoordinator: Coordinator {
    
    let navigationController: NavigationController
    var coordinators: [Coordinator] = []
    weak var delegate: InitialWalletCoordinatorDelegate?
    let keystore: Keystore
    let enterType: EnterType
    
    init(
        keystore: Keystore,
        enterType: EnterType,
        navigationController: NavigationController
    ) {
        self.keystore = keystore
        self.enterType = enterType
        self.navigationController = navigationController
    }
    
    func start() {
        switch enterType {
        case .created:
            showCreateWallet()
        case .imported:
            showImportWallet()
        default :
            break
        }
    }
    
    fileprivate func showCreateWallet() {
        let coordinator = WalletCoordinator(
            enterType: .created,
            keystore: keystore,
            navigationController: navigationController
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    fileprivate func showImportWallet() {
        let coordinator = WalletCoordinator(
            enterType: .imported,
            keystore: keystore,
            navigationController: navigationController
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
}

extension InitialWalletCoordinator: WalletCoordinatorDelegate {
    func didCancel(in coordinator: WalletCoordinator) {
        delegate?.didCancel(in: self)
        removeCoordinator(coordinator)
    }
    func didFinish(with account: WalletInfo, enterType: EnterType, in coordinator: WalletCoordinator) {
        delegate?.didAddAccount(account, in: self)
        removeCoordinator(coordinator)
        switch enterType {
        case .created:
            Dex4DProvider.shared.loginLog(address: account.currentAccount.address.description, type: "mword")
        default:
            break
        }
    }
}


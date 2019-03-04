//
//  SettingsCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

final class MeCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let session: WalletSession
    let keystore: Keystore
    let account: WalletInfo
    let tokensStorage: TokensDataStore
    
    var amountValue: String?
    
    let navigationController: NavigationController = NavigationController()
    
    lazy var rootViewController: MeViewController = {
        let vc = MeViewController(keystore: keystore, account: account)
        vc.delegate = self
        return vc
    }()
    
    init(
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore,
        tabBarItem: UITabBarItem
    ) {
        self.session = session
        self.keystore = keystore
        self.account = session.account
        self.tokensStorage = tokensStorage
        rootViewController.tabBarItem = tabBarItem
        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        navigationController.viewControllers = [rootViewController]
    }
    
    func send(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        nonceProvider: GetNonceProvider,
        chainState: ChainState,
        method: PayMethod,
        navController: UINavigationController
    ) {
        let configurator =  DexTransactionConfigurator(
            session: session,
            account: session.account.currentAccount,
            transaction: transaction,
            chainState: chainState,
            type: type,
            token: DexTokenObject(),
            nonceProvider: nonceProvider
        )
        let coordinator = DexConfirmSendCoordinator(
            session: session,
            keystore: keystore,
            configurator: configurator,
            method: method,
            navigationController: navigationController
        )
        
        coordinator.didCompleted = {[weak self] (result, txHash, isAuth)in
            guard let `self` = self else { return }
            switch result {
            case .success(let confirmResult):
                self.removeCoordinator(coordinator)
                switch confirmResult {
                case .sentTransaction(_):
                    if let txHash = txHash {
                        let controller = TradeSuccessViewController(configurator: configurator, txHash: txHash)
                        controller.delegate = self
                        navController.pushViewController(controller, animated: true)
                    }
                case .signedTransaction: break
                }
            case .failure(let error):
                navController.topViewController?.showTipsMessage(message: error.localizedDescription)
            }
        }
    }
    
    func pushToQRCode() {
        let vc = ShowQRCodeViewController(address: session.account.currentAccount.address.description, showType: .referral)
        navigationController.pushViewController(vc, animated: true)
    }
}

extension MeCoordinator: AuthorityPayViewControllerDelegate {
    func pushToNickName(count: Double, chainState: ChainState) {
        let vc = NickNameViewController(count: count, chainState: chainState)
        vc.delegate = self
        navigationController.pushViewController(vc, animated: true)
    }
    func didPressPayForSwap(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        chainState: ChainState,
        in viewController: UIViewController
    ) {
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: transfer.server, address: session.account.address)
        nonceProvider.fetch {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.send(
                    transaction: transaction,
                    transfer: transfer,
                    type: type,
                    nonceProvider: nonceProvider,
                    chainState: chainState,
                    method: .defaultPay,
                    navController: viewController.navigationController!
                )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension MeCoordinator: NickNameViewControllerDelegate {
    func didPressPay(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        chainState: ChainState,
        in viewController: UIViewController
    ) {
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: transfer.server, address: session.account.address)
        nonceProvider.fetch {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.send(
                    transaction: transaction,
                    transfer: transfer,
                    type: type,
                    nonceProvider: nonceProvider,
                    chainState: chainState,
                    method: .defaultPay,
                    navController: self.navigationController
                )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension MeCoordinator: TradeSuccessViewControllerDelegate {
    func didPressDone(in viewController: UIViewController, type: D4DTransferActionType) {
        switch type {
        case .buyReferralAuthority(_):
            NotificationCenter.default.post(name: NotificationNames.autorityPaySuccess, object: nil)
        case .buySwapAuthority:
            NotificationCenter.default.post(name: NotificationNames.autorityPaySuccess, object: nil)
        default:
            break
        }
    }
}

extension MeCoordinator: DexConfirmSendCoordinatorDelegate {
    func didCancelToSend(in coordinator: DexConfirmSendCoordinator) {
        removeCoordinator(coordinator)
    }
}

//
//  TokensCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

final class TokensCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let keystore: Keystore
    let session: WalletSession
    let store: TokensDataStore
    
    let navigationController: NavigationController = NavigationController()
    
    lazy var rootViewController: WalletViewController = {
        let tokensViewModel = TokensViewModel(session: session, store: store)
        return WalletViewController(viewModel: tokensViewModel)
    }()
    
    init(
        keystore: Keystore,
        tokensStorage: TokensDataStore,
        session: WalletSession,
        tabBarItem: UITabBarItem
    ) {
        self.keystore = keystore
        self.store = tokensStorage
        self.session = session
        rootViewController.tabBarItem = tabBarItem
        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        showTokens()
    }
    
    private func showTokens() {
        rootViewController.delegate = self
        navigationController.viewControllers = [rootViewController]
    }
    
    func sendFlow(controller: NavigationController) {
        switch session.account.type {
        case .privateKey, .hd:
            let first = session.account.accounts.filter { $0.coin == Coin.ethereum}.first
            guard let account = first else { return }
            
            let coordinator = SendCoordinator(
                navigationController: controller,
                session: session,
                keystore: keystore,
                account: account
            )
            addCoordinator(coordinator)
            coordinator.delegate = self
            coordinator.start()
        case .address: break
        }
    }
    
    func pushToReceive() {
        let vc = ShowQRCodeViewController(address: session.account.currentAccount.address.description)
        navigationController.pushViewController(vc, animated: true)
    }
    
    func pushToSend(nvc: NavigationController? = nil) {
        sendFlow(controller: nvc ?? navigationController)
    }
}

extension TokensCoordinator: WalletViewControllerDelegate {

    func didCheckHistory(in viewController: UIViewController) {
        let vc = HistoryTransferController()
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    
    func didSelectReceive(account: Account, in viewController: UIViewController) {

        let vc = ShowQRCodeViewController(address: account.address.description)
        viewController.navigationController?.pushViewController(vc, animated: true)
    }
    func didSelectSend(in viewController: UIViewController) {
        if let nvc = viewController.navigationController as? NavigationController {
            pushToSend(nvc: nvc)
        } else {
            pushToSend()
        }
    }
}

extension TokensCoordinator: SendCoordinatorDelegate {
    func didFinishedSendToken(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
    }
    func didCancelSendToken(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
    }
}

//
//  DexCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import RealmSwift

final class HomeCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let keystore: Keystore
    let session: WalletSession
    let dexTokenStorage: DexTokenStorage
    let dexTransactionStore: DexTransactionsStorage
    let realm: Realm
    
    let chainState = ChainState(server: RPCServer())
    
    let navigationController: NavigationController = NavigationController()
    
    lazy var rootViewController: HomeViewController = {
        let vc = HomeViewController(
            session: session,
            dexTokenStorage: dexTokenStorage,
            config: DexConfig.current,
            dexTransactionStore: dexTransactionStore
        )
        vc.delegate = self
        return vc
    }()
    
    init(
        keystore: Keystore,
        session: WalletSession,
        realm: Realm,
        tabBarItem: UITabBarItem
    ) {
        self.keystore = keystore
        self.session = session
        self.realm = realm
        self.dexTokenStorage = DexTokenStorage(realm: realm)
        self.dexTransactionStore = DexTransactionsStorage(realm: realm)
        rootViewController.tabBarItem = tabBarItem
        navigationController.navigationBar.isHidden = true
    }
    
    func start() {
        navigationController.viewControllers = [rootViewController]
    }
    
    func goToDexTransferCoordinator(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        nonceProvider: GetNonceProvider,
        qrInfo: String,
        controller: UIViewController
    ) {
        let tokenPool = rootViewController.viewModel.pools?.filter { $0.tokenName == token.name}.first
        guard let pool = tokenPool else { return }
        let coordinator = DexTransferCoordinator(
            keystore: keystore,
            session: session,
            pool: pool,
            viewModel: rootViewController.viewModel,
            dexTokenStorage: dexTokenStorage,
            chainState: chainState,
            navigationController: controller.navigationController ?? UINavigationController()
        )
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.send(
            transaction: transaction,
            transfer: transfer,
            token: token,
            type: type,
            nonceProvider: nonceProvider,
            method: .scan(qrInfo: qrInfo),
            controller: controller
        )
    }
    
    func goToWithdrawCoordinator(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        nonceProvider: GetNonceProvider,
        qrInfo: String,
        controller: UIViewController
    ) {
        let coordinator = WithdrawCoordinator(
            navigationController: controller.navigationController as! NavigationController,
            session: session,
            keystore: keystore,
            accountViewModel: rootViewController.viewModel
        )
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.send(
            transaction: transaction,
            transfer: transfer,
            token: token,
            type: type,
            nonceProvider: nonceProvider,
            method: .scan(qrInfo: qrInfo),
            controller: controller
        )
    }
    
    func goToMeCoordinator(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        nonceProvider: GetNonceProvider,
        qrInfo: String,
        controller: UIViewController
    ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator, let meCoordinator = main.coordinators.last as? MeCoordinator {
            meCoordinator.send(
                transaction: transaction,
                transfer: transfer,
                type: type,
                nonceProvider: nonceProvider,
                chainState: chainState,
                method: .scan(qrInfo: qrInfo),
                navController: controller.navigationController ?? UINavigationController()
            )
        }
    }
    
    func gotoScanCoordinator(in viewController: UIViewController? = nil) {
        let coordinator = ScanCoordinator(
            targetController: viewController ?? navigationController,
            session: session,
            navigationController: navigationController
        )
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start()
    }
}

extension HomeCoordinator: HomeViewControllerDelegate {
    func didPressedScan(in viewController: UIViewController) {
        gotoScanCoordinator(in: viewController)
    }
    func didPressHeaderView(for viewModel: DexAccountViewModel, viewController: UIViewController) {
        let dexAccountController = Dex4DAccountViewController(
            keystore: keystore,
            account: session.account,
            viewModel: viewModel,
            dexTransactionStore: dexTransactionStore
        )
        dexAccountController.delegate = self
        viewController.navigationController?.pushViewController(dexAccountController, animated: true)
    }
    
}

extension HomeCoordinator: SendCoordinatorDelegate {
    func didFinishedSendToken(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
    }
    func didCancelSendToken(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension HomeCoordinator: Dex4DAccountViewControllerDelegate {
    func checkoutTransaction(in viewController: UIViewController) {
        let controller = TransactionsViewController(dexTransactionStore: dexTransactionStore)
        viewController.navigationController?.pushViewController(controller, animated: true)
    }
    
    func didPressedWithdraw(for viewModel: DexAccountViewModel, viewController: UIViewController) {
        let coordinator = WithdrawCoordinator(
            navigationController: viewController.navigationController as! NavigationController,
            session: session,
            keystore: keystore,
            accountViewModel: viewModel
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func didSelectedTradeOperation(for pool: DexPool, viewModel: DexAccountViewModel, viewController: UIViewController) {
        let coordinator = DexTransferCoordinator(
            keystore: keystore,
            session: session,
            pool: pool,
            viewModel: viewModel,
            dexTokenStorage: dexTokenStorage,
            chainState: chainState,
            navigationController: viewController.navigationController ?? UINavigationController()
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
}

extension HomeCoordinator: DexTransferCoordinatorDelegate {
    func didFinishTransaction(with coordinator: Coordinator) {
        removeCoordinator(coordinator)
    }
    func didCancelTradeAction(in coordinator: Coordinator) {
        removeCoordinator(coordinator)
    }
}

extension HomeCoordinator: WithdrawCoordinatorDelegate {
    func didFinishWithdrawAction(in coordinator: WithdrawCoordinator) {
        removeCoordinator(coordinator)
    }
    func didCancelWithdrawAction(in coordinator: WithdrawCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension HomeCoordinator: ScanCoordinatorDelegate {
    
    func scanPayment(for payData: ScanPaymentInfo, qrInfo: String, viewController: UIViewController) {
        guard let token = payData.getTokenObject(tokens: rootViewController.viewModel.tokenObjects) else { return }
        let transaction = DexUnconfirmedTransaction(
            transfer: payData.transfer,
            value: payData.value,
            to: payData.getToAddress(token: token),
            data: Data(),
            gasLimit: payData.inputGasLimit,
            gasPrice: chainState.gasPrice,
            nonce: .none
        )
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: payData.transfer.server, address: session.account.address)
        nonceProvider.fetch {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                if let type = payData.transferActionType {
                    switch type {
                    case .withdraw:
                        self.goToWithdrawCoordinator(
                            transaction: transaction,
                            transfer: payData.transfer,
                            token: token,
                            type: type,
                            nonceProvider: nonceProvider,
                            qrInfo: qrInfo,
                            controller: viewController
                        )
                    case .buyReferralAuthority, .buySwapAuthority:
                        self.goToMeCoordinator(
                            transaction: transaction,
                            transfer: payData.transfer,
                            type: type,
                            nonceProvider: nonceProvider,
                            qrInfo: qrInfo,
                            controller: viewController
                        )
                    default:
                        self.goToDexTransferCoordinator(
                            transaction: transaction,
                            transfer: payData.transfer,
                            token: token,
                            type: type,
                            nonceProvider: nonceProvider,
                            qrInfo: qrInfo,
                            controller: viewController
                        )
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func scanCompleted(in coordinator: ScanCoordinator) {
        removeCoordinator(coordinator)
    }
    
    func scanResult(for address: String, coordinator: ScanCoordinator) {
        removeCoordinator(coordinator)
        switch session.account.type {
        case .privateKey, .hd:
            let first = session.account.accounts.filter { $0.coin == Coin.ethereum }.first
            guard let account = first else { return }
            let sendCoordinator = SendCoordinator(
                navigationController: navigationController,
                session: session,
                keystore: keystore,
                account: account
            )
            addCoordinator(sendCoordinator)
            sendCoordinator.delegate = self
            sendCoordinator.fetch(address: address)
        case .address: break
        }
    }
}

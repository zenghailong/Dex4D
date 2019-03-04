//
//  WithdrawCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/6.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol WithdrawCoordinatorDelegate: class {
    func didCancelWithdrawAction(in coordinator: WithdrawCoordinator)
    func didFinishWithdrawAction(in coordinator: WithdrawCoordinator)
}

final class WithdrawCoordinator: Coordinator {
    
    weak var delegate: WithdrawCoordinatorDelegate?
    
    var coordinators: [Coordinator] = []
    
    let chainState = ChainState(server: RPCServer())
    
    let session: WalletSession
    let navigationController: NavigationController
    let keystore: Keystore
    let accountViewModel: DexAccountViewModel
    
    var amountValue: String = "0"
    
    init(
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        accountViewModel: DexAccountViewModel
    ) {
        self.navigationController = navigationController
        self.session = session
        self.keystore = keystore
        self.accountViewModel = accountViewModel
    }
    
    func start() {
        let controller = WithDrawViewController(
            accountViewModel: accountViewModel,
            chainState: chainState,
            tokensStorage: session.tokensStorage
        )
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
    
    func send(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        nonceProvider: GetNonceProvider,
        method: PayMethod,
        controller: UIViewController
    ) {
        let configurator =  DexTransactionConfigurator(
            session: session,
            account: session.account.currentAccount,
            transaction: transaction,
            chainState: chainState,
            type: type,
            token: token,
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
                case .sentTransaction(let transaction):
                    if let txHash = txHash {
                        let controller = TradeSuccessViewController(configurator: configurator, txHash: txHash)
                        controller.delegate = self
                        self.navigationController.pushViewController(controller, animated: true)
                        switch transaction.payType {
                        case .defaultPay:
                            self.sendActionLog(txHash: txHash, configurator: configurator, data: transaction.data.hexEncoded, transaction: transaction.original)
                        case .scan(_): break
                        }
                    }
                case .signedTransaction: break
                }
            case .failure(let error):
                self.navigationController.topViewController?.showTipsMessage(message: error.localizedDescription)
            }
        }
        addCoordinator(coordinator)
    }
    
    private func sendActionLog(txHash: String, configurator: DexTransactionConfigurator, data: String, transaction: SignTransaction) {
        let loggers: [String: Any]
        let amount = EtherNumberFormatter.full.string(from: configurator.transaction.value, decimals: DexConfig.decimals)
        let amountStr = amount.replacingOccurrences(of: ",", with: "")
        let amountA = Double(amountStr)?.stringFloor6Value() ?? "0"
        let amountB =  Double(amountValue)?.stringFloor6Value() ?? "0"
        switch configurator.type {
        case .withdraw(let symbol):
            loggers = [
                "account": configurator.account.address.description,
                "symbol": symbol,
                "create_time": Date.getCurrentTime(),
                "swapA": symbol,
                "swapB": symbol,
                "chainId": configurator.chainState.server.chainID,
                "txHash": txHash,
                "from": configurator.account.address.description,
                "to": DexConfig.dex_protocol,
                "data": data,
                "gasPrice": String(format: "%0x", Int64(transaction.gasPrice)).add0x,
                "gasLimit": String(format: "%0x", Int64(transaction.gasLimit)).add0x,
                "desc": "withdraw",
                "amountA": amountA,
                "amountB": amountB
            ]
        default: loggers = [:]
        }
        Dex4DProvider.shared.writeActionLog(input: loggers)
    }
}

extension WithdrawCoordinator: WithDrawViewControllerDelegate {
    func didPressConfirm(transaction: DexUnconfirmedTransaction, transfer: Dex4DTransfer, token: DexTokenObject, type: D4DTransferActionType, amount: String, in viewController: UIViewController) {
        amountValue = amount
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: transfer.server, address: session.account.address)
        nonceProvider.fetch {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.send(
                    transaction: transaction,
                    transfer: transfer,
                    token: token,
                    type: type,
                    nonceProvider: nonceProvider,
                    method: .defaultPay,
                    controller: viewController
                )
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func didCancelWithdraw(in controller: UIViewController) {
        delegate?.didCancelWithdrawAction(in: self)
    }
    
}

extension WithdrawCoordinator: TradeSuccessViewControllerDelegate {
    func didPressDone(in viewController: UIViewController, type: D4DTransferActionType) {
        delegate?.didFinishWithdrawAction(in: self)
    }
}

extension WithdrawCoordinator: DexConfirmSendCoordinatorDelegate {
    func didCancelToSend(in coordinator: DexConfirmSendCoordinator) {
        removeCoordinator(coordinator)
    }
}

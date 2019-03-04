//
//  DexTransferCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
enum PayMethod {
    case scan(qrInfo: String)
    case defaultPay
}
protocol DexTransferCoordinatorDelegate: class {
    func didCancelTradeAction(in coordinator: Coordinator)
    func didFinishTransaction(with coordinator: Coordinator)
}

class DexTransferCoordinator: Coordinator {
    
    weak var delegate: DexTransferCoordinatorDelegate?
    
    var coordinators: [Coordinator] = []
    
    var amountValue: String = "0"
    
    let keystore: Keystore
    let session: WalletSession
    let pool: DexPool
    let viewModel: DexAccountViewModel
    let dexTokenStorage: DexTokenStorage
    let chainState: ChainState
    let navigationController: UINavigationController
    
    init(
        keystore: Keystore,
        session: WalletSession,
        pool: DexPool,
        viewModel: DexAccountViewModel,
        dexTokenStorage: DexTokenStorage,
        chainState: ChainState,
        navigationController: UINavigationController
    ) {
        self.keystore = keystore
        self.session = session
        self.pool = pool
        self.viewModel = viewModel
        self.dexTokenStorage = dexTokenStorage
        self.chainState = chainState
        self.navigationController = navigationController
    }
    
    func start() {
        let controller = TradeViewController(
            account: session.account,
            pool: pool,
            viewModel: viewModel,
            dexTokenStorage: dexTokenStorage,
            tokensStorage: session.tokensStorage,
            chainState: chainState
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
        var isAuthorized = false
        switch type {
        case .buy(let tokenName):
            isAuthorized = tokenName == "eth" ? false : true
        default: break
        }
        
        let configurator =  DexTransactionConfigurator(
            session: session,
            account: session.account.currentAccount,
            transaction: transaction,
            chainState: chainState,
            isAuthorized: isAuthorized,
            type: type,
            token: token,
            nonceProvider: nonceProvider
        )
        
        let coordinator = DexConfirmSendCoordinator(
            session: session,
            keystore: keystore,
            configurator: configurator,
            isAuthorized: isAuthorized,
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
                    self.didCompletedToSend(
                        configurator: configurator,
                        txHash: txHash,
                        transaction: transaction,
                        data: transaction.data.hexEncoded
                    )
                case .signedTransaction: break
                }
            case .failure(let error):
                self.delegate?.didCancelTradeAction(in: self)
                self.navigationController.topViewController?.showTipsMessage(message: error.localizedDescription)
            }
        }
        addCoordinator(coordinator)
    }
    
    func didCompletedToSend(configurator: DexTransactionConfigurator, txHash: String?, transaction: SentTransaction, data: String) {
        if let txHash = txHash {
            let controller = TradeSuccessViewController(configurator: configurator, txHash: txHash)
            controller.delegate = self
            navigationController.pushViewController(controller, animated: true)
            switch transaction.payType {
            case .defaultPay:
                self.sendActionLog(txHash: txHash, configurator: configurator, data: transaction.data.hexEncoded, transaction: transaction.original)
            case .scan(_): break
            }
        }
    }
    
    private func sendActionLog(txHash: String, configurator: DexTransactionConfigurator, data: String, transaction: SignTransaction) {
        let loggers: [String: Any]
        let amount = EtherNumberFormatter.full.string(from: configurator.transaction.value, decimals: DexConfig.decimals)
        let amountStr = amount.replacingOccurrences(of: ",", with: "")
        let amountA = Double(amountStr)?.stringFloor6Value() ?? "0"
        let amountB =  Double(amountValue)?.stringFloor6Value() ?? "0"
        switch configurator.type {
        case .buy(let symbol):
            loggers = [
                "account": configurator.account.address.description,
                "symbol": symbol,
                "create_time": Date.getCurrentTime(),
                "swapA": symbol,
                "swapB": "d4d",
                "chainId": configurator.chainState.server.chainID,
                "txHash": txHash,
                "from": configurator.account.address.description,
                "to": DexConfig.dex_protocol,
                "data": data,
                "gasPrice": String(format: "%0x", Int64(transaction.gasPrice)).add0x,
                "gasLimit": String(format: "%0x", Int64(transaction.gasLimit)).add0x,
                "desc": "buy",
                "amountA": amountA,
                "amountB": amountB
            ]
        case .reinvest(let symbol):
            loggers = [
                "account": configurator.account.address.description,
                "symbol": symbol,
                "create_time": Date.getCurrentTime(),
                "swapA": symbol,
                "swapB": "d4d",
                "chainId": configurator.chainState.server.chainID,
                "txHash": txHash,
                "from": configurator.account.address.description,
                "to": DexConfig.dex_protocol,
                "data": data,
                "gasPrice": String(format: "%0x", Int64(transaction.gasPrice)).add0x,
                "gasLimit": String(format: "%0x", Int64(transaction.gasLimit)).add0x,
                "desc": "reinvest",
                "amountA": amountA,
                "amountB": amountB
            ]
        case .sell(let symbol):
            loggers = [
                "account": configurator.account.address.description,
                "symbol": symbol,
                "create_time": Date.getCurrentTime(),
                "swapA": symbol,
                "swapB": "d4d",
                "chainId": configurator.chainState.server.chainID,
                "txHash": txHash,
                "from": configurator.account.address.description,
                "to": DexConfig.dex_protocol,
                "data": data,
                "gasPrice": String(format: "%0x", Int64(transaction.gasPrice)).add0x,
                "gasLimit": String(format: "%0x", Int64(transaction.gasLimit)).add0x,
                "desc": "sell",
                "amountA": amountA,
                "amountB": amountB
            ]
        case .swap(let symbol, let toSymbol):
            loggers = [
                "account": configurator.account.address.description,
                "symbol": symbol,
                "create_time": Date.getCurrentTime(),
                "swapA": symbol,
                "swapB": toSymbol,
                "chainId": configurator.chainState.server.chainID,
                "txHash": txHash,
                "from": configurator.account.address.description,
                "to": DexConfig.dex_protocol,
                "data": data,
                "gasPrice": String(format: "%0x", Int64(transaction.gasPrice)).add0x,
                "gasLimit": String(format: "%0x", Int64(transaction.gasLimit)).add0x,
                "desc": "swap",
                "amountA": amountA,
                "amountB": amountB
            ]
        default: loggers = [:]
        }
        Dex4DProvider.shared.writeActionLog(input: loggers)
    }
}

extension DexTransferCoordinator: TradeViewControllerDelegate {
    func didPressConfirm(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        amount: String,
        in viewController: UIViewController
    ) {
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
    
    func didCancelTradeAction(in viewController: UIViewController) {
        delegate?.didCancelTradeAction(in: self)
    }
}

extension DexTransferCoordinator: TradeSuccessViewControllerDelegate {
    func didPressDone(in viewController: UIViewController, type: D4DTransferActionType) {
        delegate?.didFinishTransaction(with: self)
    }
}

extension DexTransferCoordinator: DexConfirmSendCoordinatorDelegate {
    func didCancelToSend(in coordinator: DexConfirmSendCoordinator) {
        removeCoordinator(coordinator)
    }
}

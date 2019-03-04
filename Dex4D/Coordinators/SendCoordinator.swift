//
//  SendCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/17.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import Rswift
import Result

protocol SendCoordinatorDelegate: class {
    func didCancelSendToken(in coordinator: SendCoordinator)
    func didFinishedSendToken(in coordinator: SendCoordinator)
}

final class SendCoordinator: Coordinator {
    
    weak var delegate: SendCoordinatorDelegate?
    
    //let transfer: Transfer
    let session: WalletSession
    let account: Account
    let navigationController: NavigationController
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    
    init(
        // transfer: Transfer,
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.session = session
        self.account = account
        self.keystore = keystore
    }
    
    func start() {
        let viewModel = SendViewModel(
            server: RPCServer(),
            store: session.tokensStorage
        )
        let controller = SendViewController(viewModel: viewModel)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
    
    func fetch(address: String) {
        let viewModel = SendViewModel(
            server: RPCServer(),
            store: session.tokensStorage,
            address: address
        )
        let controller = SendViewController(viewModel: viewModel)
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
    
    func send(
        unconfirmedTransaction: UnconfirmedTransaction,
        transfer: Transfer,
        token: TokenObject,
        nonceProvider: GetNonceProvider,
        viewController: SendViewController
    ) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: unconfirmedTransaction,
            server: transfer.server,
            chainState: ChainState(server: transfer.server),
            nonceProvider: nonceProvider
        )
        
        let coordinator = ConfirmSendCoordinator(
            session: session,
            keystore: keystore,
            confirmType: .signThenSend,
            server: transfer.server,
            configurator: configurator,
            account: account,
            token: token,
            navigationController: navigationController
        )
        coordinator.didCompleted = { [weak self] (result, txHash)in
            guard let `self` = self else { return }
            switch result {
            case .success(let confirmResult):
                self.removeCoordinator(coordinator)
                switch confirmResult {
                case .sentTransaction(let transaction):
                    if let txHash = txHash {
                        let controller = SendSuccessController(
                            sentTransaction: transaction,
                            txHash: txHash,
                            token: token,
                            transfer: transfer
                        )
                        controller.delegate = self
                        viewController.navigationController?.pushViewController(controller, animated: true)
                        self.handlePendingTransaction(txHash: txHash, sentTransaction: transaction, token: token, unconfirmedTransaction: unconfirmedTransaction)
                    }
                case .signedTransaction: break
                }
            case .failure(let error):
                self.delegate?.didCancelSendToken(in: self)
                self.navigationController.topViewController?.showTipsMessage(message: error.localizedDescription)
            }
        }
        coordinator.delegate = self
        addCoordinator(coordinator)
    }
    
    func handlePendingTransaction(txHash: String, sentTransaction: SentTransaction, token: TokenObject, unconfirmedTransaction: UnconfirmedTransaction) {
        let value = EtherNumberFormatter.full.string(from: unconfirmedTransaction.value, decimals: token.decimals)
        let sendValue = value.replacingOccurrences(of: ",", with: "")
        let transaction = SentTransaction.from(transaction: sentTransaction, txhash: txHash, token: token, sendValue: sendValue)
        let parameters: [String : Any] = [
            "from": transaction.from,
            "to": transaction.to,
            "value": transaction.value,
            "nonce": transaction.nonce,
            "gaslimit": transaction.gaslimit,
            "gasprice": transaction.gasprice,
            "txhash": txHash
        ]
        print(parameters)
        let _ = provider.request(.addTransactionObject(parameters: parameters)) {[weak self] result in
            switch result {
            case .success(let responseObject):
                if let response = JSONResponseFormatter(responseObject.data) {
                    print(response)
                    if let state = response["state"] as? Int, state == 1 {
                        self?.session.transactionsStorage.add([transaction])
                    }
                }
            case .failure(_): break
            }
        }
        
    }
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressContinue(transaction: UnconfirmedTransaction, transfer: Transfer, token: TokenObject, in viewController: SendViewController) {
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: transfer.server, address: account.address)
        nonceProvider.fetch {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(_):
                self.send(unconfirmedTransaction: transaction, transfer: transfer, token: token, nonceProvider: nonceProvider, viewController: viewController)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    func didPressSelectToken(in viewController: UIViewController) {
        let selectTokenController = SelectTokenController(titleText: "Token select".localized, store: session.tokensStorage)
        viewController.navigationController?.pushViewController(selectTokenController, animated: true)
    }
    func didCancel(in viewController: UIViewController) {
        delegate?.didCancelSendToken(in: self)
    }
}

extension SendCoordinator: SendSuccessControllerDelegate {
    func didPressedDone(in viewController: SendSuccessController, sentTransaction: SentTransaction, callbackId: Int?) {
        delegate?.didFinishedSendToken(in: self)
    }
}

extension SendCoordinator: ConfirmSendCoordinatorDelegate {
    func didCancelToSend(in coordinator: ConfirmSendCoordinator) {
        removeCoordinator(coordinator)
    }
}

//
//  SendTransactionCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

protocol SendTransactionCoordinatorDeleagte: class {
    func didCompletedToSend(result: Result<ConfirmResult, AnyError>, _ txHash: String?)
}

final class SendTransactionCoordinator: Coordinator {
    
    weak var delegate: SendTransactionCoordinatorDeleagte?
    
    var coordinators: [Coordinator] = []
    
    private let keystore: Keystore
    
    var txHash: String?
    let confirmType: ConfirmType
    let configurator: TransactionConfigurator
    let account: Account
    let viewController: UIViewController
    
    init(
        keystore: Keystore,
        confirmType: ConfirmType,
        configurator: TransactionConfigurator,
        account: Account,
        viewController: UIViewController
    ) {
        self.keystore = keystore
        self.confirmType = confirmType
        self.account = account
        self.configurator = configurator
        self.viewController = viewController
    }
    
    func fetch() {
        viewController.displayLoading()
        configurator.load { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.sendAction()
            case .failure(let error):
                self.viewController.hideLoading()
                self.viewController.showTipsMessage(message: error.localizedDescription)
            }
        }
    }
    
    func sendAction() {
        let transaction = configurator.signTransaction
        send(transaction: transaction) { [weak self] result in
            guard let `self` = self else { return }
            self.delegate?.didCompletedToSend(result: result, self.txHash)
            self.viewController.hideLoading()
        }
    }
    
    func send(transaction: SignTransaction, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        if transaction.nonce >= 0 {
            signAndSend(transaction: transaction, completion: completion)
        } else {
            let _ = provider.request(.getNonce(id: 2, jsonrpc: "2.0", method: "contractservice_getNonce", params: [transaction.account.address.description])) {[weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let responseObject):
                    if let response = JSONResponseFormatter(responseObject.data), let nonce = response["result"] as? String {
                        if let nonce = BigInt(nonce, radix: 10) {
                            let transaction = self.appendNonce(to: transaction, currentNonce: nonce)
                            self.signAndSend(transaction: transaction, completion: completion)
                        }
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    private func signAndSend(transaction: SignTransaction, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        let signedTransaction = keystore.signTransaction(transaction)
        switch signedTransaction {
        case .success(let data):
            approve(confirmType: confirmType, transaction: transaction, data: data, completion: completion)
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
    
    private func approve(confirmType: ConfirmType, transaction: SignTransaction, data: Data, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        let id = data.sha3(.keccak256).hexEncoded
        let sentTransaction = SentTransaction(
            id: id,
            original: transaction,
            data: data,
            payType: .defaultPay
        )
        let dataHex = data.hexEncoded
        switch confirmType {
        case .sign:
            completion(.success(.sentTransaction(sentTransaction)))
        case .signThenSend:
            let _ = provider.request(.send(id: 2, jsonrpc: "2.0", method: "contractservice_sendRawTransaction", params: [dataHex])) {[weak self] result in
                switch result {
                case .success(let responseObject):
                    if let response = JSONResponseFormatter(responseObject.data) {
                        if let _ = response["error"] {
                            self?.viewController.hideLoading()
                            self?.viewController.showTipsMessage(message: "Send failure".localized)
                            return
                        }
                        let txHash = response["result"] as? String
                        self?.txHash = txHash
                        Config.current.defaults.set(String(transaction.nonce), forKey: Config.Keys.latestNonce)
                        Config.current.defaults.synchronize()
                        completion(.success(.sentTransaction(sentTransaction)))
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    private func appendNonce(to: SignTransaction, currentNonce: BigInt) -> SignTransaction {
        return SignTransaction(
            value: to.value,
            account: to.account,
            to: to.to,
            nonce: currentNonce,
            data: to.data,
            gasPrice: to.gasPrice,
            gasLimit: to.gasLimit,
            chainID: to.chainID,
            localizedObject: to.localizedObject
        )
    }
    
}

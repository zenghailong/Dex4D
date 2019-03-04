//
//  DexSendTransferCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/31.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

protocol DexSendTransferCoordinatorDeleagte: class {
    func didCompletedToSend(result: Result<ConfirmResult, AnyError>, _ txHash: String?, isAuthorized: Bool)
}

class DexSendTransferCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    weak var delegate: DexSendTransferCoordinatorDeleagte?
    
    private let keystore: Keystore
    let method: PayMethod
    var txHash: String?
    let configurator: DexTransactionConfigurator
    let viewController: UIViewController
    let isAuthCompleted: Bool
    let isAuthorized: Bool
    
    init(
        keystore: Keystore,
        configurator: DexTransactionConfigurator,
        isAuthCompleted: Bool = false,
        isAuthorized: Bool = false,
        method: PayMethod,
        viewController: UIViewController
    ) {
        self.keystore = keystore
        self.configurator = configurator
        self.isAuthCompleted = isAuthCompleted
        self.isAuthorized = isAuthorized
        self.method = method
        self.viewController = viewController
    }
    
    func fetch() {
        if isAuthCompleted == false {
           viewController.displayLoading()
        }
        configurator.load {[weak self] result in
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
            self.delegate?.didCompletedToSend(result: result, self.txHash, isAuthorized: self.isAuthorized)
            if self.isAuthorized == false {
               self.viewController.hideLoading()
            }
        }
    }
    
    func send(transaction: SignTransaction, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        if transaction.nonce >= 0 {
            signThenSend(transaction: transaction, completion: completion)
        } else {
            let _ = provider.request(.getNonce(id: 2, jsonrpc: "2.0", method: "contractservice_getNonce", params: [transaction.account.address.description])) {[weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let responseObject):
                    if let response = JSONResponseFormatter(responseObject.data), let nonce = response["result"] as? String {
                        if let nonce = BigInt(nonce, radix: 10) {
                            let transaction = self.appendNonce(to: transaction, currentNonce: nonce)
                            self.signThenSend(transaction: transaction, completion: completion)
                        }
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }
    
    private func signThenSend(transaction: SignTransaction, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
       
        let signedTransaction = keystore.signTransaction(transaction)
        switch signedTransaction {
        case .success(let data):
            approve(transaction: transaction, data: data, completion: completion)
        case .failure(let error):
            completion(.failure(AnyError(error)))
        }
    }
    
    private func approve(transaction: SignTransaction, data: Data, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
       
        let id = data.sha3(.keccak256).hexEncoded
        let sentTransaction = SentTransaction(
            id: id,
            original: transaction,
            data: data,
            payType: method
        )
        let dataHex = data.hexEncoded
        
        switch method {
        case .scan(let qrInfo):
            let appName = qrInfo.qrStringAppName()
            let address = qrInfo.qrStringAddress()
            let nonce = qrInfo.qrStringNonce()
            let sign = [address, nonce, "true", dataHex].joined(separator: "&").md5String()
            ScanProvider.shared.qrPayConfirm(
                appname: appName,
                nonce: nonce,
                address: address,
                confirm: "true",
                txdata: dataHex,
                sign: sign
            ) {[weak self] result in
                switch result {
                case .success(let response):
                    if let state = response["state"] as? Int, state == 1 {
                        let txHash = response["txhash"] as? String
                        self?.handleResponse(sentTransaction, hashValue: txHash, completion: completion)
                    } else {
                        let error = response["error"] as? [String: String]
                        self?.viewController.hideLoading()
                        self?.viewController.showTipsMessage(message: scanPayError[error?["id"] ?? "1"])
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        case .defaultPay:
            let _ = provider.request(.send(id: 2, jsonrpc: "2.0", method: "contractservice_sendRawTransaction", params: [dataHex])) {[weak self] result in
                switch result {
                case .success(let responseObject):
                    if let response = JSONResponseFormatter(responseObject.data) {
                        print(response)
                        if let _ = response["error"] {
                            self?.viewController.hideLoading()
                            self?.viewController.showTipsMessage(message: "Send failure".localized)
                            return
                        }
                        let txHash = response["result"] as? String
                        self?.handleResponse(sentTransaction, hashValue: txHash, completion: completion)
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
    
    private func handleResponse(_ sentTransaction: SentTransaction, hashValue: String?, completion: @escaping (Result<ConfirmResult, AnyError>) -> Void) {
        Config.current.defaults.set(String(sentTransaction.original.nonce), forKey: Config.Keys.latestNonce)
        Config.current.defaults.synchronize()
        txHash = hashValue
        completion(.success(.sentTransaction(sentTransaction)))
    }
}

//
//  TransactionConfigurator.swift
//  Dex4D
//
//  Created by zeng hai long on 19/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

final class TransactionConfigurator {
    let session: WalletSession
    let account: Account
    let transaction: UnconfirmedTransaction
    let forceFetchNonce: Bool
    let server: RPCServer
    let chainState: ChainState
    var configuration: TransactionConfiguration {
        didSet {
            configurationUpdate.value = configuration
        }
    }
    var requestEstimateGas: Bool
    
    let nonceProvider: NonceProvider
    
    var configurationUpdate: Subscribable<TransactionConfiguration> = Subscribable(nil)
    
    init(
        session: WalletSession,
        account: Account,
        transaction: UnconfirmedTransaction,
        server: RPCServer,
        chainState: ChainState,
        forceFetchNonce: Bool = true,
        nonceProvider: NonceProvider
    ) {
        self.session = session
        self.account = account
        self.transaction = transaction
        self.server = server
        self.chainState = chainState
        self.forceFetchNonce = forceFetchNonce
        self.requestEstimateGas = transaction.gasLimit == .none
        let data: Data = TransactionConfigurator.data(for: transaction, from: account.address)
        let calculatedGasLimit = transaction.gasLimit ?? TransactionConfigurator.gasLimit(for: transaction.transfer.type)
        let calculatedGasPrice = min(max(transaction.gasPrice ?? chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max)
        
        self.nonceProvider = nonceProvider
        self.configuration = TransactionConfiguration(
            gasPrice: calculatedGasPrice,
            gasLimit: calculatedGasLimit,
            data: data,
            nonce: transaction.nonce ?? BigInt(nonceProvider.nextNonce ?? -1)
        )
    }
    
    private static func data(for transaction: UnconfirmedTransaction, from: Address) -> Data {
        guard let to = transaction.to else { return Data() }
        switch transaction.transfer.type {
        case .ether, .dapp:
            return transaction.data ?? Data()
        case .token:
            return ERC20Encoder.encodeTransfer(to: to, tokens: transaction.value.magnitude)
        }
    }
    
    private static func gasLimit(for type: TransferType) -> BigInt {
        switch type {
        case .ether:
            return GasLimitConfiguration.default
        case .token:
            return GasLimitConfiguration.tokenTransfer
        case .dapp:
            return GasLimitConfiguration.dappTransfer
        }
    }
    
    func load(completion: @escaping (Result<Void, AnyError>) -> Void) {
        loadNonce(completion: completion)
    }
    
    func estimateGasLimit(completion: @escaping (Result<Void, AnyError>) -> Void) {
        let params = [signTransaction.data.hexEncoded, transaction.to?.description.lowercased() ?? ""]
        let _ = provider.request(.getEstimateGas(id: 1, jsonrpc: "2.0", method: "contractservice_estimateGas", params: params)) {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let responseData):
//                if let response = JSONResponseFormatter(responseData.data), let gas = response["result"] as? Int64 {
//                    self.refreshGasLimit(BigInt(gas) * 20 / 100 + BigInt(gas))
//                }
                completion(.success(()))
            case .failure(_): break
            }
        }
    }

    func loadNonce(completion: @escaping (Result<Void, AnyError>) -> Void) {
        nonceProvider.getNextNonce(force: forceFetchNonce) { [weak self] result in
            switch result {
            case .success(let nonce):
                self?.refreshNonce(nonce)
                self?.estimateGasLimit(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func valueToSend() -> BigInt {
        var value = transaction.value
        switch transaction.transfer.type.token.type {
        case .coin:
            let balanceValue = EtherNumberFormatter.full.number(from: transaction.transfer.type.token.value, units: .ether) ?? BigInt(0)
            //let balance = Balance(value: transaction.transfer.type.token.valueBigInt)
            if !balanceValue.isZero && balanceValue - configuration.gasLimit * configuration.gasPrice < transaction.value {
                value = balanceValue - configuration.gasLimit * configuration.gasPrice
                //We work only with positive numbers.
                if value.sign == .minus {
                    value = BigInt(value.magnitude)
                }
            }
            return value
        case .ERC20:
            return value
        }
    }
    
    var signTransaction: SignTransaction {
        let value: BigInt = {
            switch transaction.transfer.type {
            case .ether: return valueToSend()
            case .dapp: return transaction.value
            case .token: return 0
            }
        }()
        let address: EthereumAddress? = {
            switch transaction.transfer.type {
            case .ether, .dapp: return transaction.to
            case .token(let token): return token.contractAddress
            }
        }()
        let localizedObject: LocalizedOperationObject? = {
            switch transaction.transfer.type {
            case .ether, .dapp: return .none
            case .token(let token):
                return LocalizedOperationObject(
                    from: account.address.description,
                    to: transaction.to?.description ?? "",
                    contract: token.contract,
                    type: OperationType.tokenTransfer.rawValue,
                    value: BigInt(transaction.value.magnitude).description,
                    symbol: token.symbol,
                    name: token.name,
                    decimals: token.decimals
                )
            }
        }()
        
        let signTransaction = SignTransaction(
            value: value,
            account: account,
            to: address,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: server.chainID,
            localizedObject: localizedObject
        )
        
        return signTransaction
    }
    
    func refreshNonce(_ nonce: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            data: configuration.data,
            nonce: nonce
        )
    }
    
    func refreshGasLimit(_ gasLimit: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: gasLimit,
            data: configuration.data,
            nonce: configuration.nonce
        )
    }
    
}

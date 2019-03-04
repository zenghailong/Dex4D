//
//  DexTransactionConfigurator.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/31.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

final class DexTransactionConfigurator {
    
    let session: WalletSession
    let account: Account
    let transaction: DexUnconfirmedTransaction
    let forceFetchNonce: Bool
    let isAuthorized: Bool
    let type: D4DTransferActionType
    let token: DexTokenObject
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
        transaction: DexUnconfirmedTransaction,
        chainState: ChainState,
        forceFetchNonce: Bool = true,
        isAuthorized: Bool = false,
        type: D4DTransferActionType,
        token: DexTokenObject,
        nonceProvider: NonceProvider
    ) {
        self.session = session
        self.account = account
        self.transaction = transaction
        self.chainState = chainState
        self.forceFetchNonce = forceFetchNonce
        self.isAuthorized = isAuthorized
        self.type = type
        self.token = token
        self.requestEstimateGas = transaction.gasLimit == .none
        self.nonceProvider = nonceProvider
        let data: Data = DexTransactionConfigurator.data(for: transaction, type: type, isAuthorized: isAuthorized, token: token, from: account.address)
        let calculatedGasLimit = transaction.gasLimit ?? DexTransactionConfigurator.gasLimited(for: type, isAuthorized: isAuthorized)
        let calculatedGasPrice = min(max(transaction.gasPrice ?? chainState.gasPrice ?? GasPriceConfiguration.default, GasPriceConfiguration.min), GasPriceConfiguration.max)
        self.configuration = TransactionConfiguration(
            gasPrice: calculatedGasPrice,
            gasLimit: calculatedGasLimit,
            data: data,
            nonce: transaction.nonce ?? BigInt(nonceProvider.nextNonce ?? -1)
        )
    }
    
    private static func data(for transaction: DexUnconfirmedTransaction, type: D4DTransferActionType, isAuthorized: Bool, token: DexTokenObject, from: Address) -> Data {
        switch type {
        case .buy(let symbol):
            if symbol == "eth" {
                let referAddress = UserDefaults.getStringValue(for: Dex4DKeys.invitationCode)
                return D4DEncoder.encodeDexOperation(type: .buy(symbol: symbol, amount: transaction.value.magnitude, referredBy: EthereumAddress(string: referAddress) ?? EthereumAddress.zero))
            }
            if isAuthorized {
                guard let spender = EthereumAddress(string: token.dealer_addr) else { return Data() }
                return D4DEncoder.encodeApprove(spender: spender, tokens: transaction.value.magnitude)
            }
            return D4DEncoder.encodeDexOperation(type: .buy(symbol: symbol, amount: transaction.value.magnitude, referredBy: EthereumAddress.zero))
        case .reinvest(let symbol):
            return D4DEncoder.encodeDexOperation(type: .reinvest(symbol: symbol, amount: transaction.value.magnitude))
        case .sell(let symbol):
            return D4DEncoder.encodeDexOperation(type: .sell(symbol: symbol, amount: transaction.value.magnitude))
        case .swap(let symbol, let toSymbol):
            return D4DEncoder.encodeDexOperation(type: .arbitrageTokens(fromSymbol: symbol, toSymbol: toSymbol, amount: transaction.value.magnitude))
        case .withdraw(let symbol):
            return D4DEncoder.encodeDexOperation(type: .withdraw(symbol: symbol, amount: transaction.value.magnitude))
        case .buyReferralAuthority(let nick):
            return D4DEncoder.encodeDexOperation(type: .buyReferral(nick: nick))
        case .buySwapAuthority:
            return D4DEncoder.encodeDexOperation(type: .buyArbitrage)
        }
    }
    
    private static func gasLimited(for type: D4DTransferActionType, isAuthorized: Bool) -> BigInt {
        switch type {
        case .buy(let symbol):
            if symbol == "eth" {
                return DexGasLimitConfiguration.configurateContractGasLimit(type: .buy)
            }
            if isAuthorized {
                return DexGasLimitConfiguration.approve
            }
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .buy)
        case .reinvest:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .reinvest)
        case .sell:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .sell)
        case .swap:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .swap)
        case .withdraw:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .withdraw)
        case .buyReferralAuthority, .buySwapAuthority:
            return DexGasLimitConfiguration.default

        }
    }
    
    func load(completion: @escaping (Result<Void, AnyError>) -> Void) {
        loadNonce(completion: completion)
    }
    
    func loadNonce(completion: @escaping (Result<Void, AnyError>) -> Void) {
        nonceProvider.getNextNonce(force: forceFetchNonce) { [weak self] result in
            switch result {
            case .success(let nonce):
                var newNonce = nonce
                if let nextNonce = self?.nonceProvider.nextNonce {
                    newNonce = max(nonce, nextNonce)
                }
                self?.refreshNonce(newNonce)
                //self?.estimateGasLimit(completion: completion)
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
//    func estimateGasLimit(completion: @escaping (Result<Void, AnyError>) -> Void) {
//        let params = [signTransaction.data.hexEncoded, transaction.to?.description.lowercased() ?? ""]
//        let _ = provider.request(.getEstimateGas(id: 1, jsonrpc: "2.0", method: "contractservice_estimateGas", params: params)) {[weak self] result in
//            guard let `self` = self else { return }
//            switch result {
//            case .success(let responseData): break
//                //                if let response = JSONResponseFormatter(responseData.data), let gas = response["result"] as? Int64 {
//                //                    self.refreshGasLimit(BigInt(gas) * 20 / 100 + BigInt(gas))
//                //                }
//            case .failure(_): break
//            }
//        }
//    }
    
    func refreshNonce(_ nonce: BigInt) {
        configuration = TransactionConfiguration(
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            data: configuration.data,
            nonce: nonce
        )
    }
    
    func valueToSend() -> BigInt {
        return transaction.value
    }
    
    var signTransaction: SignTransaction {
        let value: BigInt = {
            switch transaction.transfer.type {
            case .ether: return valueToSend()
            case .token: return 0
            }
        }()
        
        let signTransaction = SignTransaction(
            value: value,
            account: account,
            to: transaction.to,
            nonce: configuration.nonce,
            data: configuration.data,
            gasPrice: configuration.gasPrice,
            gasLimit: configuration.gasLimit,
            chainID: chainState.server.chainID,
            localizedObject: nil
        )
        
        return signTransaction
    }
}

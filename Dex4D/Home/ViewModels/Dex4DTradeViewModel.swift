//
//  Dex4DTradeViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt
import Result

final class Dex4DTradeViewModel {
    
    let style: Dex4DTradeViewStyle
    let coin: String
    let chainState: ChainState
    
    var requestTransferPriceCompleted: ((DexPoolMarketInfo) -> Swift.Void)?
    
    init(
        style: Dex4DTradeViewStyle,
        coin: String,
        chainState: ChainState
    ) {
        self.style = style
        self.coin = coin
        self.chainState = chainState
        self.fetch()
    }
    
    var tradeTitleText: String {
        switch style {
        case .withdraw:
            return "Withdraw amount".localized
        case .buy:
            return "Buy amount".localized
        case .reinvest:
            return "Reinvest amount".localized
        case .sell:
            return "Sell amount".localized
        case .swap:
            return "D4D amount".localized
        }
    }
    
    var submitButtonText: String {
        switch style {
        case .withdraw:
            return "Withdraw".localized
        default:
            return "Confirm".localized
        }
    }
    
    func fetch() {
        getTrasferPrice(token: coin)
    }
    
    private func getTrasferPrice(token: String) {
        Dex4DProvider.shared.getDex4DPoolMarketInfo(coin: token) {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let marketInfo):
                self.requestTransferPriceCompleted?(marketInfo)
            case .failure(_):
                break
            }
        }
    }
    
    func getDex4DCount(tokenValue: String, symbol: String, completion: @escaping (String) -> Swift.Void) {
        Dex4DProvider.shared.getDex4DCount(by: symbol, tokenCount: tokenValue) { result in
            switch result {
            case .success(let count):
                completion(count)
            case .failure(_): break
            }
        }
    }
    
    func getTokenReceivedCount(dexCount: String, symbol: String, completion: @escaping (String) -> Swift.Void) {
        Dex4DProvider.shared.getCoinCountSellDex4D(coin: symbol, count: dexCount) { result in
            switch result {
            case .success(let count):
                completion(count.replacingOccurrences(of: ",", with: ""))
            case .failure(_): break
            }
        }
    }
    
    func getTokenSpendCount(coin: String, count: String, completion: @escaping (String) -> Swift.Void) {
        Dex4DProvider.shared.getSpendTokenCountByBuyDex4D(coin: coin, count: count) { result in
            switch result {
            case .success(let count):
                completion(count.replacingOccurrences(of: ",", with: ""))
            case .failure(_): break
            }
        }
    }
    
    func calculatedGasUsed() -> BigInt {
        return getTransferGasLimited() * (chainState.gasPrice ?? BigInt())
    }
    
    private func getTransferGasLimited() -> BigInt {
        switch style {
        case .buy:
            if coin == "eth" {
                return DexGasLimitConfiguration.configurateContractGasLimit(type: .buy)
            }
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .buy) +  DexGasLimitConfiguration.approve
        case .reinvest:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .reinvest)
        case .sell:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .sell)
        case .swap:
            return DexGasLimitConfiguration.configurateContractGasLimit(type: .swap)
        default: break
        }
        return DexGasLimitConfiguration.default
    }
    
    func ethBalance(address: String, completion: @escaping (Result<Balance, NetRequestError>) -> Void) {
        print(address)
        let _ = provider.request(.getEtherBalance(id: 2, jsonrpc: "2.0", method: "contractservice_getBalance", params: [address])) { (result) in
            switch result {
            case .success(let responseObject):
                if let response = JSONResponseFormatter(responseObject.data), let balance = response["result"] as? String, let value = BigInt(balance.drop0x, radix: 16) {
                    completion(.success(Balance(value: value)))
                }
            case .failure(_):
                completion(.failure(.failedRequestToGetBalance))
            }
        }
    }
    
    func tokenBalance(address: String, contract: String, completion: @escaping (Result<Balance, NetRequestError>) -> Void) {
        let _ = provider.request(.getEtherBalance(id: 2, jsonrpc: "2.0", method: "contractservice_erc20Balance", params: [contract, address])) { (result) in
            switch result {
            case .success(let responseObject):
                if let response = JSONResponseFormatter(responseObject.data), let balance = response["result"] as? String, let value = BigInt(balance.drop0x, radix: 16) {
                    completion(.success(Balance(value: value)))
                }
            case .failure(_):
                completion(.failure(.failedRequestToGetBalance))
            }
        }
    }
}


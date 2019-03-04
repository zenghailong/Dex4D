//
//  BalanceNetworkProvider.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/12.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

protocol BalanceNetworkProvider {
    var addressUpdate: EthereumAddress { get }
    func balance(completion: @escaping (Result<Balance, NetRequestError>) -> Void)
}

final class CoinNetworkProvider: BalanceNetworkProvider {
    
    let address: Address
    
    let addressUpdate: EthereumAddress
    
    init(address: Address, addressUpdate: EthereumAddress) {
        self.address = address
        self.addressUpdate = addressUpdate
    }
    
    func balance(completion: @escaping (Result<Balance, NetRequestError>) -> Void) {
        let _ = provider.request(.getEtherBalance(id: 2, jsonrpc: "2.0", method: "contractservice_getBalance", params: [address.description])) { (result) in
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


final class TokenNetworkProvider: BalanceNetworkProvider {
    
    let address: EthereumAddress
    let contract: EthereumAddress
    let addressUpdate: EthereumAddress
    
    init( address: EthereumAddress,
          contract: EthereumAddress,
          addressUpdate: EthereumAddress
    ) {
        self.address = address
        self.contract = contract
        self.addressUpdate = addressUpdate
    }
    
    func balance(completion: @escaping (Result<Balance, NetRequestError>) -> Void) {
        let _ = provider.request(.getEtherBalance(id: 2, jsonrpc: "2.0", method: "contractservice_erc20Balance", params: [contract.description, address.description])) { (result) in
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

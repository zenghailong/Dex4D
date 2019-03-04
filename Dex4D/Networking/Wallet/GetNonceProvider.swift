//
//  GetNonceProvider.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import Result

protocol NonceProvider {
    var remoteNonce: BigInt? { get }
    var latestNonce: BigInt? { get }
    var nextNonce: BigInt? { get }
    var nonceAvailable: Bool { get }
    func getNextNonce(force: Bool, completion: @escaping (Result<BigInt, AnyError>) -> Void)
}


final class GetNonceProvider: NonceProvider {
    
    let storage: TransactionsStorage
    let server: RPCServer
    let address: Address
    var remoteNonce: BigInt? = .none
    var latestNonce: BigInt? {
//        guard let nonce = storage.latestTransaction(for: address, coin: server.coin)?.nonce else {
//            return .none
//        }
        guard let nonce = Config.current.defaults.string(forKey: Config.Keys.latestNonce) else {
            return .none
        }
        let remoteNonceInt = remoteNonce ?? BigInt(-1)
        return max(BigInt(nonce) ?? BigInt(-1), remoteNonceInt)
    }
    
    var nextNonce: BigInt? {
        guard let latestNonce = latestNonce else {
            return .none
        }
        return latestNonce + 1
    }
    
    var nonceAvailable: Bool {
        return latestNonce != nil
    }
    
    init(
        storage: TransactionsStorage,
        server: RPCServer,
        address: Address
    ) {
        self.storage = storage
        self.server = server
        self.address = address
       // fetchLatestNonce()
    }
    
//    func fetchLatestNonce() {
//        fetch { _ in }
//    }
    
    func getNextNonce(force: Bool = false, completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        guard let nextNonce = nextNonce, force == false else {
            return fetchNextNonce(completion: completion)
        }
        completion(.success(nextNonce))
    }
    
    func fetchNextNonce(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        fetch { result in
            switch result {
            case .success(let nonce):
                completion(.success(nonce + 1))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func fetch(completion: @escaping (Result<BigInt, AnyError>) -> Void) {
        let _ = provider.request(.getNonce(id: 2, jsonrpc: "2.0", method: "contractservice_getNonce", params: [address.description])) {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let responseObject):
                if let response = JSONResponseFormatter(responseObject.data), let nonce = response["result"] as? String {
                    if let nonce = BigInt(nonce, radix: 10) {
                        self.remoteNonce = nonce - 1
                        completion(.success(nonce - 1))
                    }
                }
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}

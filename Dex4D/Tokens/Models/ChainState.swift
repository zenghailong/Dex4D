//
//  ChainState.swift
//  Dex4D
//
//  Created by zeng hai long on 18/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

final class ChainState {
    
    struct Keys {
        static let latestBlock = "chainID"
        static let gasPrice = "gasPrice"
    }
    
    let server: RPCServer
    
    private var latestBlockKey: String {
        return "\(server.chainID)-" + Keys.latestBlock
    }
    
    private var gasPriceBlockKey: String {
        return "\(server.chainID)-" + Keys.gasPrice
    }
    
    var latestBlock: Int {
        get {
            return defaults.integer(forKey: latestBlockKey)
        }
        set {
            defaults.set(newValue, forKey: latestBlockKey)
        }
    }
    var gasPrice: BigInt? {
        get {
            guard let value = defaults.string(forKey: gasPriceBlockKey) else { return .none }
            return BigInt(value, radix: 10)
        }
        set { defaults.set(newValue?.description, forKey: gasPriceBlockKey) }
    }
    
    let defaults: UserDefaults
    
    init(server: RPCServer) {
        self.server = server
        self.defaults = Config.current.defaults
        fetch()
    }
    
    func start() {
        fetch()
    }
    
    @objc func fetch() {
        getLastBlock()
        getGasPrice()
    }
    
    private func getLastBlock() {
    }
    
    private func getGasPrice() {
        let _ = provider.request(.getGasPrice(id: 2, jsonrpc: "2.0", method: "contractservice_gasPrice", params: [])) { (result) in
            switch result {
            case .success(let responseObject):
                if let response = JSONResponseFormatter(responseObject.data), let gasPrice = response["result"] as? Int64 {
                    self.gasPrice = BigInt(gasPrice)
                }
            case .failure(_):
                break
            }
        }
    }
}

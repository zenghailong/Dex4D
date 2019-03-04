//
//  SendViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/17.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

struct SendViewModel {
    
    let server: RPCServer
    let chainState: ChainState
    let store: TokensDataStore
    
    var tokenObject: TokenObject? = .none
    
    var titleText: String {
        return "Send".localized
    }
    
    var continueButtonText: String {
        return "Confirm".localized
    }
    
    var gasPrice: BigInt? {
        return chainState.gasPrice
    }
    
    var tokenType: String?
    var address: String?
    
    init(
        server: RPCServer,
        store: TokensDataStore,
        address: String? = nil,
        token: String? = nil,
        count: Double? = nil,
        nickname: String? = nil
    ) {
        self.address = address
        self.tokenType = token
        self.server = server
        self.store = store
        self.chainState = ChainState(server: self.server)
        self.chainState.fetch()
    }
    
    func showBalance(for token: TokenObject) -> String {
        guard token.value == TokenObject.DEFAULT_VALUE else {
            return token.value.doubleValue.stringFloor6Value()
        }
        return token.value
    }
    
    func getToken() -> TokenObject? {
        if let symbol = tokenType {
            for token in store.tokens {
                if token.symbol == symbol {
                    return token
                }
            }
        }
        return nil
    }
}

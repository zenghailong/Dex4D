//
//  WalletInfo.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/9.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct WalletInfo {
    let type: WalletStyle
    let info: WalletObject
    
    var address: Address {
        switch type {
        case .privateKey, .hd:
            return currentAccount.address
        case .address(_, let address):
            return address
        }
    }
    
    var multiWallet: Bool {
        return accounts.count > 1
    }
    
    var mainWallet: Bool {
        return info.mainWallet
    }
    
    var accounts: [Account] {
        switch type {
        case .privateKey(let account), .hd(let account):
            return account.accounts
        case .address(let coin, let address):
            return [
                Account(wallet: .none, address: address, derivationPath: coin.derivationPath(at: 0)),
            ]
        }
    }
    
    var currentAccount: Account! {
        switch type {
        case .privateKey, .hd:
            return accounts.first //.filter { $0.description == info.selectedAccount }.first ?? accounts.first!
        case .address(let coin, let address):
            return Account(wallet: .none, address: address, derivationPath: coin.derivationPath(at: 0))
        }
    }
    
    var currentWallet: Wallet? {
        switch type {
        case .privateKey(let wallet), .hd(let wallet):
            return wallet
        case .address:
            return .none
        }
    }
    
    init(
        type: WalletStyle,
        info: WalletObject? = .none
    ) {
        self.type = type
        self.info = info ?? WalletObject.from(type)
    }
    
    var description: String {
        return type.description
    }
}

extension WalletInfo: Equatable {
    static func == (lhs: WalletInfo, rhs: WalletInfo) -> Bool {
        return lhs.type.description == rhs.type.description
    }
}

//extension WalletInfo {
//    static func format(value: String, server: RPCServer) -> String {
//        return "\(value) \(server.symbol)"
//    }
//}

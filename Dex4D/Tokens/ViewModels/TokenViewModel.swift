//
//  TokenViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

final class TokenViewModel {
    
    
    static func balance(for token: TokenObject, wallet: WalletInfo) -> BalanceNetworkProvider? {
        let first = wallet.accounts.filter { $0.coin == token.coin }.first
        guard let account = first else { return .none }
        let networkBalance: BalanceNetworkProvider? = {
            switch token.type {
            case .coin:
                return CoinNetworkProvider(
                    address: EthereumAddress(string: account.address.description)!,
                    addressUpdate: token.address
                )
            case .ERC20:
                return TokenNetworkProvider(
                    address: EthereumAddress(string: account.address.description)!,
                    contract: token.contractAddress,
                    addressUpdate: token.address
                )
            }
        }()
        return networkBalance
    }
    
    
}

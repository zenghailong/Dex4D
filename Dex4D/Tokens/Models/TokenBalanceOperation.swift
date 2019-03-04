//
//  TokenBalanceOperation.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/12.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

final class TokenBalanceOperation: TrustOperation {
    private var balanceProvider: BalanceNetworkProvider
    private let store: TokensDataStore
    
    init(
        balanceProvider: BalanceNetworkProvider,
        store: TokensDataStore
    ) {
        self.balanceProvider = balanceProvider
        self.store = store
    }
    
    override func main() {
        updateBalance()
    }
    
    private func updateBalance() {

        balanceProvider.balance {[weak self] result in
            guard let strongSelf = self else {
                self?.finish()
                return
            }
            switch result {
            case .success(let balance):
                strongSelf.updateModel(with: balance.value)
            case .failure(_):
                strongSelf.finish()
            }
        }
    }
    
    private func updateModel(with balance: BigInt) {
        self.store.updateBalanceValue(balance: balance, for: balanceProvider.addressUpdate)
        self.finish()
    }
}

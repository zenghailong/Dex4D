//
//  TradeHeaderViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import RealmSwift

final class TradeHeaderViewModel {
    
    let pool: DexPool
    
    let dexTokenStorage: DexTokenStorage
    
    var tokenSymbol: String {
        return pool.tokenName
    }
    
    var totalVolumText: String {
        return "Token balance".localized
    }
    
    var totalDividendsText: String {
        return "D4D balance".localized
    }
    
    var notificationToken: NotificationToken?
    
    var getPoolMarketCapCompleted: ((DexMarketcap) -> Swift.Void)?
    
    init(
        pool: DexPool,
        dexTokenStorage: DexTokenStorage
    ) {
        self.pool = pool
        self.dexTokenStorage = dexTokenStorage
        startTokenObservation()
    }
    
    private func startTokenObservation() {
        notificationToken = dexTokenStorage.marketcapObjects.observe { [weak self] (changes: RealmCollectionChange) in
            guard let `self` = self else { return }
            switch changes {
            case .initial, .update:
                let poolMarketObjects = self.dexTokenStorage.marketcapObjects.filter { $0.symbol == self.pool.tokenName }
                if !poolMarketObjects.isEmpty {
                    self.getPoolMarketCapCompleted?(poolMarketObjects.first!)
                    
                }
            case .error(let error):
                fatalError("\(error)")
            }
            
        }
    }

    deinit {
        notificationToken?.invalidate()
        notificationToken = nil
    }
}

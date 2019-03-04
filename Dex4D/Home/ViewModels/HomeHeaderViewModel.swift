//
//  HomeHeaderViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/19.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import RealmSwift

class HomeHeaderViewModel: NSObject {
    
    let config: DexConfig
    let transactionStore: DexTransactionsStorage
    
    var notificationTransaction: NotificationToken?
    
    var capitalTitleLabelText = "Total capital(All pools)".localized
    var capitalTitleLabelFont = UIFont.defaultFont(size: 12)
    var capitalTitleLabelColor = Colors.textAlpha
    
    var capitalValueLabelText: String = "0.00"
    var capitalValueLabelFont = UIFont.defaultFont(size: 48)
    var capitalValueLabelColor = UIColor.white
    
    //var pendingLabelText = String(format: "%d Transaction Pending", 0)
    var pendingLabelFont = UIFont.defaultFont(size: 12)
    var pendingLabelColor = UIColor.white
    
    var tokenBalanceTitleLabelText = "Total Token balance".localized
    var tokenBalanceTitleLabelFont = UIFont.defaultFont(size: 12)
    var tokenBalanceTitleLabelColor = Colors.textAlpha
    
    var tokenBalanceValueLabelText: String =  "0.00"
    var tokenBalanceValueLabelFont = UIFont.defaultFont(size: 16)
    var tokenBalanceValueLabelColor = UIColor.white
    
    var dex4dTitleLabelText = "Total D4D balance".localized
    var dex4dTitleLabelFont = UIFont.defaultFont(size: 12)
    var dex4dTitleLabelColor = Colors.textAlpha
    
    var dex4dValueLabelText: String = "0"
    var dex4dValueLabelFont = UIFont.defaultFont(size: 16)
    var dex4dValueLabelColor = UIColor.white
    
    var backgroundViewColor = UIColor(hex: "2D788A", alpha: 0.15)
    
    init(config: DexConfig, transactionStore: DexTransactionsStorage) {
        self.config = config
        self.transactionStore = transactionStore
    }
    
    func setTransactionObservation(with block: @escaping (RealmCollectionChange<Results<DexTransaction>>) -> Void) {
        notificationTransaction = transactionStore.transactions.observe(block)
    }
    
    deinit {
        notificationTransaction?.invalidate()
    }
}

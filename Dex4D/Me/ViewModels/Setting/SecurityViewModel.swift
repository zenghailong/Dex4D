//
//  SecurityViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class SecurityViewModel {
    
    let account: WalletInfo
    
    init(account: WalletInfo) {
        self.account = account
    }
    
    var title = "Security".localized
    
    var dataSource: [CellModel] {
        if let wallet = account.currentWallet {
            switch wallet.type {
            case .encryptedKey:
                return  [
                    CellModel(title: "Backup Keystore".localized, action: "pushToKeystore")
                ]
            case .hierarchicalDeterministicWallet:
                return  [
                    CellModel(title: "Check memoric".localized, action: "pushToMemoric"),
                    CellModel(title: "Backup Keystore".localized, action: "pushToKeystore")
                ]
            }
        }
        return []
    }
        
}

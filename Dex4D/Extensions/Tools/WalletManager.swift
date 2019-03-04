//
//  WalletManager.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/27.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import RealmSwift

class WalletManager {
    
    static let shared = WalletManager()
    
    private var realm: Realm {
        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        let realm = try! Realm(configuration: sharedMigration.config)
        return realm
    }
    
    private var walletStorage: WalletStorage {
        return WalletStorage(realm: realm)
    }
    
    var keystore: EtherKeystore {
         return EtherKeystore(storage: walletStorage)
    }
    
    var hasWallet: Bool {
        guard let _ = keystore.recentlyUsedWallet ?? keystore.wallets.first else {
            return false
        }
        return true
    }
    
    var currentWalletInfo: WalletInfo? {
        guard let walletInfo = keystore.recentlyUsedWallet ?? keystore.wallets.first else {
            return nil
        }
        return walletInfo
    }
    
    var currentWallet: Wallet? {
        guard let wallet = currentWalletInfo?.currentWallet else {
            return nil
        }
        return wallet
    }
    
    var currentAccount: Account? {
        guard let account = currentWalletInfo?.currentAccount else {
            return nil
        }
        return account
    }
    
}

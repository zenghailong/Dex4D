//
//  WalletSession.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift

final class WalletSession {
    let account: WalletInfo
    let config: Config
    let realm: Realm
    let sharedRealm: Realm
    
    var sessionID: String {
        return "\(account.description))"
    }
    
    lazy var walletStorage: WalletStorage = {
        return WalletStorage(realm: sharedRealm)
    }()
    
    lazy var tokensStorage: TokensDataStore = {
        let tokensStorage = TokensDataStore(realm: realm, account: account, server: RPCServer())
        tokensStorage.addNativeCoins()
        return tokensStorage
    }()
    lazy var transactionsStorage: TransactionsStorage = {
        return TransactionsStorage(
            realm: realm,
            account: account
        )
    }()
    
    init(
        walletInfo: WalletInfo,
        realm: Realm,
        sharedRealm: Realm,
        config: Config
    ) {
        self.account = walletInfo
        self.realm = realm
        self.sharedRealm = sharedRealm
        self.config = config
    }
}

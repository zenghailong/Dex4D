//
//  WalletObject.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/28.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

enum WalletInfoField {
    case name(String)
    case backup(Bool)
    case mainWallet(Bool)
    case balance(String)
}


final class WalletObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var completedBackup: Bool = false
    @objc dynamic var mainWallet: Bool = false
    @objc dynamic var balance: String = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func from(_ type: WalletStyle) -> WalletObject {
        let info = WalletObject()
        info.id = type.description
        return info
    }
}

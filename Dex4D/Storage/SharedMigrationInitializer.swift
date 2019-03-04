//
//  SharedMigrationInitializer.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift

protocol Initializer {
    func perform()
}


final class SharedMigrationInitializer: Initializer {
    
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration()
    }()
    
    init() { }
    
    func perform() {
        config.schemaVersion = Config.dbMigrationSchemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
//            switch oldSchemaVersion {
//            case 0...52:
//                migration.deleteData(forType: CoinTicker.className)
//            default:
//                break
//            }
        }
    }
}

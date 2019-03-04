//
//  BookmarkMigrationInitializer.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import RealmSwift

final class BookmarkMigrationInitializer: Initializer {
    
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.bookmarkConfiguration()
    }()
    
    init() { }
    
    func perform() {
        config.schemaVersion = Config.dbMigrationSchemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
        }
    }
    
}

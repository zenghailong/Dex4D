//
//  DexTokenStorage.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/23.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result
import RealmSwift

final class DexTokenStorage {
    
    let realm: Realm
    
    var marketcapObjects: Results<DexMarketcap> {
        return realm.objects(DexMarketcap.self).filter(NSPredicate(format: "symbol!=''")).sorted(byKeyPath: "symbol", ascending: true)
    }
    
    init(realm: Realm) {
        self.realm = realm
    }
    

    func add(_ items: [DexMarketcap]) {
        try! realm.write {
            realm.add(items, update: true)
        }
    }
    
    func delete(tokens: [Object]) {
        try? realm.write {
            realm.delete(tokens)
        }
    }
    
    func deleteAll() {
        try? realm.write {
            realm.delete(realm.objects(DexMarketcap.self))
        }
    }
    private lazy var filePath: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let url = urls.last! as NSURL
        let filePath: URL = url.appendingPathComponent("/DexTokenStorage.plist")!
        return filePath
    }()
    
    var tokens: NSArray {
        let exist = FileManager.default.fileExists(atPath: filePath.path)
        guard exist else {
            return []
        }
        return NSArray(contentsOf: filePath)!
    }
    
    func saveDataToPlist(_ data: NSArray) {
        
        if #available(iOS 11.0, *) {
            try? data.write(to: filePath)
        } else {
            data.write(to: filePath, atomically: true)
        }
    }
}

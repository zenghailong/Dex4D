//
//  DexTransactionsStorage.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift

enum DexTransactionState: String {
    case success
    case pending
    case failed
    
    var description: String {
        switch self {
        case .success: return "Success"
        case .pending: return "Pending"
        case .failed: return "Failed"
        }
    }
}
final class DexTransactionsStorage {
    
    let realm: Realm
    var failedCount: Int = 0
    
    init(realm: Realm) {
        self.realm = realm
        failedCount = failedObjects.count
//        failedCount = successObjects.count
    }
    
    var transactions: Results<DexTransaction> {
        return realm.objects(DexTransaction.self)
            .filter(NSPredicate(format: "id!=''"))
            .sorted(byKeyPath: "time", ascending: false)
    }
    
    var allObjects: [DexTransaction] {
        return transactions.filter { $0.type != "" }
    }
    
    var pendingObjects: [DexTransaction] {
        return transactions.filter { $0.state == DexTransactionState.pending.description }
    }
    
    var successObjects: [DexTransaction] {
        return transactions.filter { $0.state == DexTransactionState.success.description }
    }
    
    var failedObjects: [DexTransaction] {
        return transactions.filter { $0.state == DexTransactionState.failed.description }
    }
    
    func get(forPrimaryKey: String) -> DexTransaction? {
        return realm.object(ofType: DexTransaction.self, forPrimaryKey: forPrimaryKey)
    }
    
    func add(_ items: [DexTransaction]) {
        try! realm.write {
            realm.add(items, update: true)
        }
    }
    
    func delete(_ items: [DexTransaction]) {
        try? realm.write {
            realm.delete(items)
        }
    }
    
    func deleteAll() {
        try? realm.write {
            realm.delete(realm.objects(DexTransaction.self))
        }
    }
}

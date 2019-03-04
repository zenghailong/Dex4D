//
//  TransactionsStorage.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift

struct TransactionSection {
    let title: String
    let items: [TransactionObject]
}

class TransactionsStorage {
    
    let realm: Realm
    
    var transactions: Results<TransactionObject> {
        return realm.objects(TransactionObject.self).filter(NSPredicate(format: "txhash!=''")).sorted(byKeyPath: "timeStamp", ascending: false)
    }
    
    let titleFormmater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d yyyy"
        return formatter
    }()
    
    var transactionSections: [TransactionSection] = []
    
    private var transactionsObserver: NotificationToken?
    
    let account: WalletInfo
    
    init(
        realm: Realm,
        account: WalletInfo
    ) {
        self.realm = realm
        self.account = account
    }
    
    func latestTransaction(for address: Address, coin: Coin) -> TransactionObject? {
        return transactions
            .filter(NSPredicate(format: "from == %@ && rawCoin == %d", address.description, coin.rawValue))
            .sorted(byKeyPath: "nonce", ascending: false)
            .first
    }
    
    var completedObjects: [TransactionObject] {
        return transactions.filter { $0.state == .completed }
    }
    
    var pendingObjects: [TransactionObject] {
        return transactions.filter { $0.state == TransactionState.pending }
    }
    
    func get(forPrimaryKey: String) -> TransactionObject? {
        return realm.object(ofType: TransactionObject.self, forPrimaryKey: forPrimaryKey)
    }
    
    func add(_ items: [TransactionObject]) {
        try! realm.write {
            realm.add(items, update: true)
        }
    }
    
    func delete(_ items: [TransactionObject]) {
        try? realm.write {
            realm.delete(items)
        }
    }
    
//    func update(state: TransactionState, for transaction: TransactionObject) {
//
//        try? realm.write {
//            let tempObject = transaction
//            tempObject.internalState = state.rawValue
//            realm.add(tempObject, update: true)
//        }
//    }
    
    func removeTransactions(for states: [TransactionState]) {
        let objects = realm.objects(TransactionObject.self).filter { states.contains($0.state) }
        try? realm.write {
            realm.delete(objects)
        }
    }
    
    func deleteAll() {
        try? realm.write {
            realm.delete(realm.objects(TransactionObject.self))
        }
    }
    
//    func updateTransactionSection() {
//        transactionSections = mappedSections(for: Array(transactions))
//    }
    
//    func mappedSections(for transactions: [TransactionObject]) -> [TransactionSection] {
//        var items = [TransactionSection]()
//        let headerDates = NSOrderedSet(array: transactions.map { titleFormmater.string(from: $0.date ) })
//        headerDates.forEach {
//            guard let dateKey = $0 as? String else {
//                return
//            }
//            let filteredTransactionByDate = Array(transactions.filter { titleFormmater.string(from: $0.date ) == dateKey })
//            items.append(TransactionSection(title: dateKey, items: filteredTransactionByDate))
//        }
//        return items
//    }
    
//    func transactionsObservation() {
//        transactionsObserver = transactions.observe { [weak self] _ in
//            self?.updateTransactionSection()
//        }
//    }
    
    deinit {
        transactionsObserver?.invalidate()
        transactionsObserver = nil
    }
}

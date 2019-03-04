//
//  DexAccountViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/23.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result
import RealmSwift

protocol DexAccountViewModelDelegate: class {
    func refresh()
    func transactionsValueChanged()
    func transactionFailed(hashArray: [String])
}

enum AccountInfo {
    case coins
    case dividends
    case rebateFees
    case d4d
    case revenue
    
    var description: String {
        switch self {
        case .coins: return "coins"
        case .dividends: return "dividends"
        case .rebateFees: return "rebateFees"
        case .d4d: return "d4d"
        case .revenue: return "revenue"
        }
    }
}

final class DexAccountViewModel {
    
    weak var delegate: DexAccountViewModelDelegate?
    
    let refreshTimeInterval: TimeInterval = 10
    
    var dexAccountInfo: [String: Any]?
    let config: DexConfig
    let account: WalletInfo
    let dexTokenStorage: DexTokenStorage
    let dexTransactionStore: DexTransactionsStorage
    
    var transactionsObserver: NotificationToken?
    
    let timer = TimerHelper.shared
    
    var tokenObjects: [DexTokenObject] {
        let tokensArr = dexTokenStorage.tokens as? Array<[String: Any]>
        if let tokensArr = tokensArr {
            return tokensArr.compactMap {
                    return DexTokenObject.deserialize(from: $0)
                }.sorted { $0.name < $1.name }
        }
        return []
    }
    
    var titleText: String {
        return account.currentAccount.address.description.addressTitleString()
    }
    
    var coins: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.coins.description) else { return nil }
            return dexAccountInfo[AccountInfo.coins.description] as? [String: Any]
        }
        return nil
    }
    
    var rebateFees: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.rebateFees.description) else { return nil }
            return dexAccountInfo[AccountInfo.rebateFees.description] as? [String: Any]
        }
        return nil
    }
    
    var d4d: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.d4d.description) else { return nil }
            return dexAccountInfo[AccountInfo.d4d.description] as? [String: Any]
        }
        return nil
    }
    
    var dividends: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.dividends.description) else { return nil }
            return dexAccountInfo[AccountInfo.dividends.description] as? [String: Any]
        }
        return nil
    }
    
    var revenue: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.revenue.description) else { return nil }
            return dexAccountInfo[AccountInfo.revenue.description] as? [String: Any]
        }
        return nil
    }
    
    var pools: [DexPool]? {
        guard tokenObjects.isEmpty == false else {
            return nil
        }
        return tokenObjects.compactMap { token in
            return DexPool(
                tokenId: token.token_id,
                tokenName: token.name,
                coin: coins?[token.name] as? Double,
                coinLegeal: coins?[token.name + "Legeal"] as? Double,
                d4dCount: d4d?[token.name] as? Double,
                d4dPrice: d4d?[token.name + "Price"] as? Double,
                revenue: revenue?[token.name] as? Double,
                revenueLegeal: revenue?[token.name + "Legeal"] as? Double,
                rebateFeelets: rebateFees?[token.name] as? Double,
                rebateFeesLegeal: rebateFees?[token.name + "Legeal"] as? Double,
                dividends: dividends?[token.name] as? Double,
                dividendsLegeal: dividends?[token.name + "Legeal"] as? Double,
                games: gamesDic[token.name] ?? []
            )
        }
    }
    
    var gamesDic: [String : [Dex4DGame]] = [:]
    
    init(
        account: WalletInfo,
        dexTokenStorage: DexTokenStorage,
        config: DexConfig,
        dexTransactionStore: DexTransactionsStorage
    ) {
        self.account = account
        self.dexTokenStorage = dexTokenStorage
        self.config = config
        self.dexTransactionStore = dexTransactionStore
        self.fetch()
        
        transactionsObserver = dexTransactionStore.transactions.observe{ (changes: RealmCollectionChange) in
            switch changes {
            case .initial, .update:
                self.delegate?.transactionsValueChanged()
//                if dexTransactionStore.successObjects.count > dexTransactionStore.failedCount {
//                    var hashArray: [String] = []
//                    for i in dexTransactionStore.failedCount..<dexTransactionStore.successObjects.count  {
//                        let transaction = dexTransactionStore.successObjects[i]
//                        hashArray.append(transaction.id)
//                    }
//                    self.delegate?.transactionFailed(hashArray: hashArray)
//                    dexTransactionStore.failedCount = dexTransactionStore.successObjects.count
//                }
                if dexTransactionStore.failedObjects.count > dexTransactionStore.failedCount {
                    var hashArray: [String] = []
                    for i in dexTransactionStore.failedCount..<dexTransactionStore.failedObjects.count  {
                        let transaction = dexTransactionStore.failedObjects[i]
                        hashArray.append(transaction.id)
                    }
                    self.delegate?.transactionFailed(hashArray: hashArray)
                    dexTransactionStore.failedCount = dexTransactionStore.failedObjects.count
                }
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer.cancleTimer(WithTimerName: Config.walletBalanceTimer)
        transactionsObserver?.invalidate()
    }
    
    func fetch() {
        WebSocketService.getPersonTradingList(account: account.address.description)
        WebSocketProvider.shared.getTransactionBlock = {[weak self] transactions in
            guard let `self` = self else { return }
            self.dexTransactionStore.add(transactions)
        }
       
        WebSocketProvider.shared.getDexDetailBlock = {[weak self] details in
            guard let `self` = self else { return }
            var validObjects: [DexMarketcap] = []
            _ = self.tokenObjects.compactMap { token in
                details.forEach { priceObject in
                    if priceObject.symbol == token.name {
                        validObjects.append(priceObject)
                    }
                }
            }
            self.dexTokenStorage.add(validObjects)
        }
        WebSocketService.getDexTokenDetail()
        
        timer.scheduledDispatchTimer(WithTimerName: Config.walletBalanceTimer, timeInterval: refreshTimeInterval, queue: .main, repeats: true) {[weak self] in
            self?.getTokenList()
        }
    }
    
    private func getTokenList() {
        Dex4DProvider.shared.getAllTokens {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let tokens):
                self.dexTokenStorage.saveDataToPlist(tokens as NSArray)
                _ = self.dexTokenStorage.marketcapObjects.compactMap { marketCap in
                    var flag = false
                    for token in tokens {
                        if token["name"] as? String == marketCap.symbol {
                            flag = true
                            break
                        }
                    }
                    if flag == false {
                        self.dexTokenStorage.delete(tokens: [marketCap])
                    }
                }
            case .failure(_):
                break
            }
            self.getDexAccountData()
        }
    }
    
    private func getDexAccountData() {
        getDexAccountInfo()
    }
    
    private func getDexAccountInfo() {
        Dex4DProvider.shared.getDex4DBalance(address: account.currentAccount.address.description) {[weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let accountInfo):
                self.dexAccountInfo = accountInfo
                self.delegate?.refresh()
                NotificationCenter.default.post(name: NotificationNames.refreshDexAccountInfoNotify, object: nil)
            case .failure(_): break
            }
        }
    }
    
    func getGames() {
        tokenObjects.forEach { (tokenObject) in
            Dex4DProvider.shared.getGames(name: tokenObject.name) { (result) in
                switch result {
                case .success(let games):
                    self.gamesDic[tokenObject.name] = games
                    self.delegate?.refresh()
                case .failure(_): break
                }
            }
        }
    }
}

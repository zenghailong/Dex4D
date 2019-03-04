//
//  TokensViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import PromiseKit
import RealmSwift
import SwiftyJSON

protocol TokensViewModelDelegate: class {
    func refreshTokens()
    func refreshTotalBalance(value: String)
}

final class TokensViewModel: NSObject {
    
    let config: Config
    let session: WalletSession
    let tokens: Results<TokenObject>
    let store: TokensDataStore
    
    var tokensObserver: NotificationToken?
    
    weak var delegate: TokensViewModelDelegate?
    
    init(
        session: WalletSession,
        config: Config = Config(),
        store: TokensDataStore
    ) {
        self.session = session
        self.config = config
        self.store = store
        self.tokens = store.tokens
    }
    
    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<TokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }
    
    func fetch() {
        updateBalances()
        updateTokensPrice()
    }
    
    func updateBalances() {
        balances(for: Array(store.tokensBalance))
    }
    
    private func balances(for tokens: [TokenObject]) {
        let balances: [BalanceNetworkProvider] = tokens.compactMap {
            return TokenViewModel.balance(for: $0, wallet: session.account)
        }
        let operationQueue: OperationQueue = OperationQueue()
        operationQueue.qualityOfService = .background
        
        let balancesOperations = Array(balances.lazy.map {
            TokenBalanceOperation(balanceProvider: $0, store: self.store)
        })
        
        operationQueue.operations.onFinish { [weak self] in
            DispatchQueue.main.async {
                self?.delegate?.refreshTokens()
            }
        }
        operationQueue.addOperations(balancesOperations, waitUntilFinished: false)
    }
    
    func invalidateTokensObservation() {
        tokensObserver?.invalidate()
        tokensObserver = nil
    }
    
    func updateTokensPrice() {
        let _ = provider.request(.getTokensPrice(coins: store.tokenSymbols, currency: LocalizationTool.shared.currentCurrency.string())) { (result) in
            switch result {
            case .success(let response):
                do {
                    let json = try JSON(data: response.data)
                    guard let data = json["result"].dictionaryObject else { return }
                    self.store.tokensPrice = data
                    guard let _ = self.store.tokens.first?.value else { return }
                    self.setTotalAsset()
                } catch {}
            case .failure(_): break
            }
        }
    }
    
    func setTotalAsset() {
        guard let tokensPrice = store.tokensPrice else {
            return
        }
        var total: Double = 0
        for token in self.store.tokens {
            if let price = tokensPrice[token.symbol] as? Double {
                total += token.value.doubleValue * price
            }
        }
        self.delegate?.refreshTotalBalance(value: total.stringFloor2Value())
    }
}

extension Array where Element: Operation {
    /// Execute block after all operations from the array.
    func onFinish(block: @escaping () -> Void) {
        let doneOperation = BlockOperation(block: block)
        self.forEach { [unowned doneOperation] in
            doneOperation.addDependency($0)
        }
        OperationQueue().addOperation(doneOperation)
    }
}

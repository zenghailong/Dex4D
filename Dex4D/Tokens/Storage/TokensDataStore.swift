//
//  TokensDataStore.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/10.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift
import BigInt

class TokensDataStore {
    
    let realm: Realm
    let account: WalletInfo
    let server: RPCServer
    
    init(
        realm: Realm,
        account: WalletInfo,
        server: RPCServer
    ) {
        self.realm = realm
        self.account = account
        self.server = server
        self.addNativeCoins()
    }
    
    var tokens: Results<TokenObject> {
        return realm.objects(TokenObject.self).filter(NSPredicate(format: "isDisabled == NO"))
            .sorted(byKeyPath: "symbol", ascending: true)
    }
    
    // tokens that needs balance and value update
    var tokensBalance: Results<TokenObject> {
        return realm.objects(TokenObject.self).filter(NSPredicate(format: "isDisabled == NO || rawType = \"coin\""))
            .sorted(byKeyPath: "order", ascending: true)
    }
    
    var tokensPrice: [String: Any]?
    
    var ethereumObject: TokenObject? {
        return tokens.filter {$0.symbol == "ETH"}.first
    }
    
    var tokenSymbols: Array<String> {
        return tokens.compactMap { return $0.symbol }
    }
    
    func addNativeCoins() {
        if let token = getToken(for: EthereumAddress.zero) {
            try? realm.write {
                realm.delete(token)
            }
        }
        let initialCoins = nativeCoin()
        
        for token in initialCoins {
            if let _ = getToken(for: token.contractAddress) {
                
            } else {
                add(tokens: [token])
                addDefaultERC20Token()
            }
        }
    }
    
    func getToken(for address: Address) -> TokenObject? {
        return realm.object(ofType: TokenObject.self, forPrimaryKey: address.description)
    }
    
    func coinTicker(by contract: Address) -> CoinTicker? {
        return realm.object(ofType: CoinTicker.self, forPrimaryKey: CoinTickerKeyMaker.makePrimaryKey(contract: contract, currencyKey: CoinTickerKeyMaker.makeCurrencyKey()))
    }
    
    private func nativeCoin() -> [TokenObject] {
        return account.accounts.compactMap { ac in
            let isDisabled: Bool = {
                return  server.isDisabledByDefault
            }()
            
            return TokenObject(
                contract: server.priceID.description,
                name: server.name,
                coin: server.coin,
                type: .coin,
                symbol: server.symbol,
                decimals: server.decimals,
                value: TokenObject.DEFAULT_VALUE,
                isCustom: false,
                isDisabled: isDisabled,
                order: server.coin.rawValue,
                logo: server.logo
            )
        }
    }
    
    func addDefaultERC20Token() {
        let tokens: [TokenObject] = server.defaultERC20.map { ERC20Token -> TokenObject in
            return TokenObject(
                contract: ERC20Token["contract"] ?? "",
                name: ERC20Token["symbol"] ?? "",
                coin: server.coin,
                type: .ERC20,
                symbol: ERC20Token["symbol"] ?? "",
                decimals: server.decimals,
                value: TokenObject.DEFAULT_VALUE,
                isCustom: true,
                logo: ERC20Token["logo"] ?? ""
            )
        }
        add(tokens: tokens)
    }
    
    func add(tokens: [Object]) {
        try? realm.write {
            if let tokenObjects = tokens as? [TokenObject] {
                let tokenObjectsWithBalance = tokenObjects.map { tokenObject -> TokenObject in
                    tokenObject.balance = self.getBalance(for: tokenObject.address, with: tokenObject.valueBigInt, and: tokenObject.decimals)
                    return tokenObject
                }
                realm.add(tokenObjectsWithBalance, update: true)
            } else {
                realm.add(tokens, update: true)
            }
        }
    }
    
    func delete(tokens: [Object]) {
        try? realm.write {
            realm.delete(tokens)
        }
    }
    
    func getBalance(for address: Address, with value: BigInt, and decimals: Int) -> Double {
        guard let ticker = coinTicker(by: address),
            let amountInDecimal = EtherNumberFormatter.full.decimal(from: value, decimals: decimals),
            let price = Double(ticker.price) else {
                return TokenObject.DEFAULT_BALANCE
        }
        return amountInDecimal.doubleValue * price
    }
    
    func getBalanceValue(with value: BigInt, and decimals: Int) -> String {
       
        let amountInDecimal = EtherNumberFormatter.full.string(from: value, decimals: decimals)
        if Double(amountInDecimal) == 0 {
            //EtherNumberFormatter.short.decimal(from: value, decimals: decimals) {
            return TokenObject.DEFAULT_VALUE
        }
        return amountInDecimal.replacingOccurrences(of: ",", with: "")
    }
    
    //Background update of the Realm model.
    func updateBalanceValue(balance: BigInt, for address: Address) {
        if let token = getToken(for: address) {
            let tokenBalance = getBalanceValue(with: balance, and: token.decimals)
            self.realm.writeAsync(obj: token) { (realm, _ ) in
                let update = self.objectToUpdate(for: (address, tokenBalance))
                realm.create(TokenObject.self, value: update, update: true)
            }
        }
    }
    
    private func objectToUpdate(for balance: (key: Address, value: String)) -> [String: Any] {
        return [
            "contract": balance.key.description,
            "value": balance.value,
        ]
    }
}

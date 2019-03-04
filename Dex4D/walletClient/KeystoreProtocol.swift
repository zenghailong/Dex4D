//
//  KeystoreProtocol.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result

enum ImportType {
    case keystore(string: String, password: String)
    case privateKey(privateKey: String)
    case mnemonic(words: [String], password: String, derivationPath: DerivationPath)
    //case address(address: EthereumAddress)
}

protocol Keystore {
    
    var hasWallets: Bool { get }
    var wallets: [WalletInfo] { get }
    var recentlyUsedWallet: WalletInfo? { get set }
    
    func createAccount(with password: String, completion: @escaping (Result<Wallet, KeystoreError>) -> Void)
    
    func importWallet(type: ImportType, coin: Coin, completion: @escaping (Result<WalletInfo, KeystoreError>) -> Void)
    
    func importKeystore(value: String, password: String, newPassword: String, coin: Coin) -> Result<WalletInfo, KeystoreError>
    
    func importPrivateKey(privateKey: PrivateKey, password: String, coin: Coin) -> Result<WalletInfo, KeystoreError>
    
    func addAccount(to wallet: Wallet, derivationPaths: [DerivationPath]) -> Result<Void, KeystoreError>
    
    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], KeystoreError>) -> Void)
    
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void)
    
    func export(wallet: Wallet, password: String, newPassword: String) -> Result<String, KeystoreError>
    
    func export(wallet: Wallet, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void)
    
    func exportData(wallet: Wallet, password: String, newPassword: String) -> Result<Data, KeystoreError>
    
    func store(object: WalletObject, fields: [WalletInfoField])
    
    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError>
}

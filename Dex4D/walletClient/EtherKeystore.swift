//
//  EtherKeystore.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result
import KeychainSwift
import BigInt

class EtherKeystore: Keystore {
    
    struct Keys {
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
        static let recentlyUsedWallet: String = "recentlyUsedWallet"
    }
    
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first ?? ""
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    private let keychain: KeychainSwift
    let keyStore: KeyStore
    
    let keysDirectory: URL
    
    let storage: WalletStorage
    
    public init(keysSubfolder: String = "/keystore",
                keychain: KeychainSwift = KeychainSwift(keyPrefix: Dex4DKeys.keychainKeyPrefix),
                storage: WalletStorage
    ) {
        self.keychain = keychain
        self.keysDirectory = URL(fileURLWithPath: datadir + keysSubfolder)
        self.keyStore = try! KeyStore(keyDirectory: keysDirectory)
        self.storage = storage
    }
    
    var hasWallets: Bool {
        return !wallets.isEmpty
    }
    
    var wallets: [WalletInfo] {
        return [
            keyStore.wallets.filter { !$0.accounts.isEmpty }.compactMap {
                switch $0.type {
                case .encryptedKey:
                    let type = WalletStyle.privateKey($0)
                    return WalletInfo(type: type, info: storage.get(for: type))
                case .hierarchicalDeterministicWallet:
                    let type = WalletStyle.hd($0)
                    return WalletInfo(type: type, info: storage.get(for: type))
                }
                }.filter { !$0.accounts.isEmpty },
            storage.addresses.compactMap {
                guard let address = $0.address else { return .none }
                let type = WalletStyle.address($0.coin, address)
                return WalletInfo(type: type, info: storage.get(for: type))
            },
            ].flatMap { $0 }.sorted(by: { $0.info.createdAt < $1.info.createdAt })
    }
    
    var recentlyUsedWallet: WalletInfo? {
        set {
            keychain.set(newValue?.description ?? "", forKey: Keys.recentlyUsedWallet, withAccess: defaultKeychainAccess)
        }
        get {
            let walletKey = keychain.get(Keys.recentlyUsedWallet)
            let foundWallet = wallets.filter { $0.description == walletKey }.first
            guard let wallet = foundWallet else {
                // Old way to match recently selected address
                let address = keychain.get(Keys.recentlyUsedAddress)
                return wallets.filter {
                    $0.address.description == address || $0.description.lowercased() == address?.lowercased()
                }.first
            }
            return wallet
        }
    }
    
    
    func createAccount(with password: String, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
        
        DispatchQueue.global().async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }
    
    func importWallet(type: ImportType, coin: Coin, completion: @escaping (Result<WalletInfo, KeystoreError>) -> Void) {
        let newPassword = PasswordGenerator.generateRandom()
        switch type {
        case .keystore(let string, let password):
            DispatchQueue.global().async {
                let result = self.importKeystore(value: string, password: password, newPassword: newPassword, coin: coin)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let account):
                        completion(.success(account))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        case .privateKey(let privateKey):
            let privateKeyData = PrivateKey(data: Data(hexString: privateKey)!)!
            DispatchQueue.global().async {
                let result = self.importPrivateKey(privateKey: privateKeyData, password: newPassword, coin: coin)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let account):
                        completion(.success(account))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        case .mnemonic(let words, let passphrase, let derivationPath):
            let string = words.map { String($0) }.joined(separator: " ")
            if !Crypto.isValid(mnemonic: string) {
                return completion(.failure(KeystoreError.invalidMnemonicPhrase))
            }
            DispatchQueue.global().async {
                let result = self.importMnemonic(mnemonic: string, passphrase: passphrase, encryptPassword: newPassword, derivationPath: derivationPath)
                DispatchQueue.main.async {
                    switch result {
                    case .success(let account):
                        completion(.success(account))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
    
    func importKeystore(value: String, password: String, newPassword: String, coin: Coin) -> Result<WalletInfo, KeystoreError> {
        guard let data = value.data(using: .utf8) else {
            return .failure(.failedToParseJSON)
        }
        do {
            //TODO: Blockchain. Pass blockchain ID
            let wallet = try keyStore.import(json: data, password: password, newPassword: newPassword, coin: coin)
            let _ = setPassword(newPassword, for: wallet)
            return .success(WalletInfo(type: .hd(wallet)))
        } catch {
            if case KeyStore.Error.accountAlreadyExists = error {
                return .failure(.duplicateAccount)
            } else {
                return .failure(.failedToImport(error))
            }
        }
    }
    
    func importMnemonic(mnemonic: String, passphrase: String, encryptPassword: String, derivationPath: DerivationPath) -> Result<WalletInfo, KeystoreError> {
        do {
            let account = try keyStore.import(mnemonic: mnemonic, passphrase: passphrase, encryptPassword: encryptPassword, derivationPath: derivationPath)
            let w = WalletInfo(type: .hd(account))
            setPassword(encryptPassword, for: account)
            return .success(w)
        } catch {
            return .failure(KeystoreError.duplicateAccount)
        }
    }
    
    func importPrivateKey(privateKey: PrivateKey, password: String, coin: Coin) -> Result<WalletInfo, KeystoreError> {
        do {
            let wallet = try keyStore.import(privateKey: privateKey, password: password, coin: coin)
            let w = WalletInfo(type: .privateKey(wallet))
            let _ = setPassword(password, for: wallet)
            return .success(w)
        } catch {
            return .failure(.failedToImport(error))
        }
    }
    
    private func createAccout(password: String) -> Wallet {
        let derivationPaths = Config.current.servers.map { $0.derivationPath(at: 0) }
        let wallet = try! keyStore.createWallet(
            password: password,
            derivationPaths: derivationPaths
        )
        let _ = setPassword(password, for: wallet)
        return wallet
    }
    
    func addAccount(to wallet: Wallet, derivationPaths: [DerivationPath]) -> Result<Void, KeystoreError> {
        guard let password = getPassword(for: wallet) else {
            return .failure(.failedToDeleteAccount)
        }
        do {
            let _ = try keyStore.addAccounts(wallet: wallet, derivationPaths: derivationPaths, password: password)
            return .success(())
        } catch {
            return .failure(KeystoreError.failedToAddAccounts)
        }
    }
    
    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], KeystoreError>) -> Void) {
        guard let password = getPassword(for: wallet) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mnemonic = try  self.keyStore.exportMnemonic(wallet: wallet, password: password)
                let words = mnemonic.components(separatedBy: " ")
                DispatchQueue.main.async {
                    completion(.success(words))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(KeystoreError.accountNotFound))
                }
            }
        }
    }
    
    func export(wallet: Wallet, password: String, newPassword: String) -> Result<String, KeystoreError> {
        let result = self.exportData(wallet: wallet, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return .success(string)
        case .failure(let error):
            return .failure(error)
        }
    }
    
    func export(wallet: Wallet, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.export(wallet: wallet, password: password, newPassword: newPassword)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func exportData(wallet: Wallet, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        do {
            let data = try keyStore.export(wallet: wallet, password: password, newPassword: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }
    
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void) {
        guard let password = getPassword(for: account.wallet!) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let privateKey = try account.privateKey(password: password).data
                DispatchQueue.main.async {
                    completion(.success(privateKey))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(KeystoreError.accountNotFound))
                }
            }
        }
    }
    
    func signTransaction(_ transaction: SignTransaction) -> Result<Data, KeystoreError> {
        let account = transaction.account
        guard let wallet  = account.wallet, let password = getPassword(for: wallet) else {
            return .failure(.failedToSignTransaction)
        }
        let signer: TransactionSigner
        if transaction.chainID == 0 {
            signer = HomesteadClientSigner()
        } else {
            signer = EIP155ClientSigner(chainId: BigInt(transaction.chainID))
        }
        
        do {
            let hash = signer.hash(transaction: transaction)
            let signature = try account.sign(hash: hash, password: password)
            let (r, s, v) = signer.values(transaction: transaction, signature: signature)
            let data = RLP.encode([
                transaction.nonce,
                transaction.gasPrice,
                transaction.gasLimit,
                transaction.to?.data ?? Data(),
                transaction.value,
                transaction.data,
                v, r, s,
                ])!
            return .success(data)
        } catch {
            return .failure(.failedToSignTransaction)
        }
    }
    
    func getPassword(for account: Wallet) -> String? {
        let key = keychainKey(for: account)
        return keychain.get(key)
    }
    
    func store(object: WalletObject, fields: [WalletInfoField]) {
        try? storage.realm.write {
            for field in fields {
                switch field {
                case .name(let name):
                    object.name = name
                case .backup(let completedBackup):
                    object.completedBackup = completedBackup
                case .mainWallet(let mainWallet):
                    object.mainWallet = mainWallet
                case .balance(let balance):
                    object.balance = balance
                }
            }
            storage.realm.add(object, update: true)
        }
    }
    
    @discardableResult
    func setPassword(_ password: String, for account: Wallet) -> Bool {
        let key = keychainKey(for: account)
        return keychain.set(password, forKey: key, withAccess: defaultKeychainAccess)
    }
    
    internal func keychainKey(for account: Wallet) -> String {
        return account.identifier
    }
}

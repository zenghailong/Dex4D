//
//  KeyStoreError.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum KeystoreError: LocalizedError {
    case failedToDeleteAccount
    case failedToImport(Error)
    case failedToParseJSON
    case duplicateAccount
    case invalidMnemonicPhrase
    case accountNotFound
    case failedToImportPrivateKey
    case failedToSignTransaction
    case failedToAddAccounts
    case failedToDecryptKey
    
    var errorDescription: String? {
        switch self {
        case .failedToImport(let error):
            return error.localizedDescription
        case .failedToParseJSON:
            return "Failed to parse key JSON"
        case .duplicateAccount:
            return "You already added this address to wallets"
        case .invalidMnemonicPhrase:
            return "Invalid mnemonic phrase"
        case .accountNotFound:
            return "Account not found"
        case .failedToImportPrivateKey:
            return "Failed to import privateKey"
        case .failedToSignTransaction:
            return "Failed to sign transaction"
        case .failedToDeleteAccount:
            return "Failed to delete account"
        case .failedToAddAccounts:
            return "Faield to add accounts"
        case .failedToDecryptKey:
            return "Could not decrypt key with given passphrase"
        }
    }
}

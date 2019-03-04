//
//  KeyChainSwift.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/27.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import KeychainSwift

class KeyChainManager {
    
    static let shared = KeyChainManager.init()
    
    private let keychain = KeychainSwift(keyPrefix: Dex4DKeys.keychainKeyPrefix)
    
    private let option = KeychainSwiftAccessOptions.accessibleWhenUnlockedThisDeviceOnly
    
    private let pinKey = Dex4DKeys.keychainKeyPrefix + ".pin"
    
    private let md5Key = Dex4DKeys.keychainKeyPrefix + ".md5"
    
    var hasPin: Bool {
        if let _ = getPin() {
            return true
        } else {
            return false
        }
    }
    
    func getPin() -> String? {
        return keychain.get(pinKey)
    }
    
    func setPin(value: String) {
        keychain.set(value, forKey: pinKey, withAccess: option)
    }
    
    func getMd5Key() -> String? {
        return keychain.get(md5Key)
    }
    
    func setMd5Key() {
        guard let _ = getPin() else {
            keychain.set(Dex4DKeys.keychainKeyPrefix, forKey: md5Key, withAccess: option)
            return
        }
    }
    
    func getValue(for key: String) -> String? {
        return keychain.get(key)
    }
    
    func set(value: String, for key: String) {
        keychain.set(value, forKey: key, withAccess: option)
    }

}

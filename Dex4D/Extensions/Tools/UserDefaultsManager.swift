//
//  UserDefaultsManager.swift
//  TradingPlatform
//
//  Created by ColdChains on 2018/9/26.
//  Copyright © 2018 冰凉的枷锁. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    class func hasValueForKey(key: String) -> Bool {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: key) == nil {
            return false
        } else {
            return true
        }
    }
    
    class func removeValue(for key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
    class func setStringValue(value: String, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getStringValue(for key: String) -> String {
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: key) as? String {
            return value
        }
        return ""
    }
    
    class func setArrayValue(value: Array<String>, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getArrayValue(for key: String) -> Array<String> {
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: key) as? Array<String> {
            return value
        }
        return []
    }
    
    class func setDictionaryValue(value: Dictionary<String, String>, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getDictionaryValue(for key: String) -> Dictionary<String, String> {
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: key) as? Dictionary<String, String> {
            return value
        }
        return [:]
    }
    
    class func setBoolValue(value: Bool, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getBoolValue(for key: String) -> Bool {
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: key) as? Bool {
            return value
        }
        return false
    }
    
    class func setDoubleValue(value: Double, key: String) {
        let defaults = UserDefaults.standard
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    
    class func getDoubleValue(for key: String) -> Double {
        let defaults = UserDefaults.standard
        if let value = defaults.object(forKey: key) as? Double {
            return value
        }
        return 0
    }
    
}


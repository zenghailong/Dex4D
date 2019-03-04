//
//  LocalizationTool.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/24.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum Language {
    case english
    case chinese
}

class LocalizationTool {
    
    static let shared = LocalizationTool()
    
    let defaults = UserDefaults.standard
    
    var bundle: Bundle?
    var currentLanguage: Language = .english
    var currentCurrency: Currency = .USD
    
    func valueWithKey(key: String) -> String {
        let bundle = LocalizationTool.shared.bundle
        if let bundle = bundle {
            return NSLocalizedString(key, tableName: "Localization", bundle: bundle, value: "", comment: "")
        } else {
            return NSLocalizedString(key, comment: "")
        }
    }
    
    func setLanguage(language: Language) {
        if currentLanguage == language {
            return
        }
        switch language {
        case .english:
            defaults.set("en", forKey: Dex4DKeys.language)
            break
        case .chinese:
            defaults.set("cn", forKey: Dex4DKeys.language)
            break
        }
        currentLanguage = getLanguage()
    }
    
    func setCurrency(currency: Currency) {
        switch currency {
        case .CNY:
            defaults.set("CNY", forKey: Dex4DKeys.currency)
            break
        default :
            defaults.set("USD", forKey: Dex4DKeys.currency)
            break
        }
        currentCurrency = getCurrency()
    }
    
    func checkLanguageAndCurrency() {
        currentLanguage = getLanguage()
        currentCurrency = getCurrency()
    }
    
    private func getLanguage() -> Language {
        var str = ""
        if let language = defaults.value(forKey: Dex4DKeys.language) as? String {
            str = language == "cn" ? "zh-Hans" : "en"
        } else {
            str = getSystemLanguage()
        }
        if let path = Bundle.main.path(forResource:str , ofType: "lproj") {
            bundle = Bundle(path: path)
        }
        return str == "en" ? .english : .chinese
    }
    
    private func getCurrency() -> Currency {
        if let currency = defaults.value(forKey: Dex4DKeys.currency) as? String {
            return currency == "CNY" ? .CNY : .USD
        } else {
            return currentLanguage == .chinese ? .CNY : .USD
        }
    }
    
    private func getSystemLanguage() -> String {
        let preferredLang = Bundle.main.preferredLocalizations.first! as NSString
        switch String(describing: preferredLang) {
        case "en-US", "en-CN":
            return "en"
        case "zh-Hans-US","zh-Hans-CN","zh-Hant-CN","zh-TW","zh-HK","zh-Hans":
            return "zh-Hans"
        default:
            return "en"
        }
    }
}

extension String {
    var localized: String {
        return LocalizationTool.shared.valueWithKey(key: self)
    }
}

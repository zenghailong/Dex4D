//
//  Config.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

struct Config {
    struct Keys {
        static let currencyID = "currencyID"
        static let latestNonce = "latestNonce"
    }
    
    struct ShowDecimals {
        static let txHashFront = 12
        static let txHashBack = 10
        static let addressFront = 12
        static let addressBack = 10
        static let amount = 6
    }
    
    static let dbMigrationSchemaVersion: UInt64 = 77
    
    static let walletBalanceTimer = "WalletBalanceTimer"
    
    static let current: Config = Config()
    
    let defaults: UserDefaults
    
    init(
        defaults: UserDefaults = UserDefaults.standard
    ) {
        self.defaults = defaults
    }
    
    var currency: Currency {
        get {
            //If it is saved currency
            if let currency = defaults.string(forKey: Keys.currencyID) {
                return Currency(rawValue: currency)!
            }
            //If ther is not saved currency try to use user local currency if it is supported.
            let avaliableCurrency = Currency.allValues.first { currency in
                return currency.rawValue == Locale.current.currencySymbol
            }
            if let isAvaliableCurrency = avaliableCurrency {
                return isAvaliableCurrency
            }
            //If non of the previous is not working return USD.
            return Currency.USD
        }
        set { defaults.set(newValue.rawValue, forKey: Keys.currencyID) }
    }
    
    var servers: [Coin] {
        return [
            Coin.ethereum
        ]
    }
}

enum Currency: String {
    case AUD
    case BRL
    case CAD
    case CHF
    case CLP
    case CNY
    case CZK
    case DKK
    case EUR
    case GBP
    case HKD
    case HUF
    case IDR
    case ILS
    case INR
    case JPY
    case KRW
    case MXN
    case MYR
    case NOK
    case NZD
    case PHP
    case PKR
    case PLN
    case RUB
    case SEK
    case SGD
    case THB
    case TRY
    case TWD
    case ZAR
    case USD
    
    static let allValues = [
        USD,
        EUR,
        GBP,
        AUD,
        RUB,
        BRL,
        CAD,
        CHF,
        CLP,
        CNY,
        CZK,
        DKK,
        HKD,
        HUF,
        IDR,
        ILS,
        INR,
        JPY,
        KRW,
        MXN,
        MYR,
        NOK,
        NZD,
        PHP,
        PKR,
        PLN,
        SEK,
        SGD,
        THB,
        TRY,
        TWD,
        ZAR,
        ]
    
    init(value: String) {
        self =  Currency(rawValue: value) ?? .USD
    }
}


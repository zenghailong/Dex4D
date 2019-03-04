//
//  DexConfig.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/23.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

public struct DexConfig {
    
    static let dex_protocol = "0xdFf9719C17CfCe12D1489BE7F83aB02c417dA01C"
    
    static let dex_referraler = "0x619e6e5B058eE1461aBeDac9789B74eB7Dd12d1C"
    

    static let current: DexConfig = DexConfig()
    
    static let formatter: String = "%.6f"
    
    static let decimals: Int = 18
    

    static let websocketBaseUrl = Dex4DUrls.websocketServerBase

    
    static let observeAccountInfoTimer = "ObserveAccountInfoTimer"
    
    var currency: String {
        return LocalizationTool.shared.currentCurrency.string()
    }
    
    var currencySymbol: String {
        return LocalizationTool.shared.currentCurrency.symbol()
    }
}



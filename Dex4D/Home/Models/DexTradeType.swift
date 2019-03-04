//
//  DexTradeType.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum Dex4DTradeType {
    case withdraw
    case buy
    case reinvest
    case sell
    case swap
}

let TRADE_TAG_BEGIN = 100

extension Dex4DTradeType {
    
    var description: String {
        switch self {
        case .buy: return "Buy".localized
        case .reinvest: return "Reinvest".localized
        case .sell: return "Sell".localized
        case .swap: return "Swap".localized
        case .withdraw: return "Withdraw".localized
        }
    }
    
    var tradeTypeId: Int {
        switch self {
        case .buy: return TRADE_TAG_BEGIN
        case .reinvest: return TRADE_TAG_BEGIN + 1
        case .sell: return TRADE_TAG_BEGIN + 2
        case .swap: return TRADE_TAG_BEGIN + 3
        case .withdraw: return TRADE_TAG_BEGIN + 4
        }
    }
}

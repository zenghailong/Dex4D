//
//  D4DTransferActionType.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/5.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum D4DTransferActionType {
    case withdraw(token: String)
    case buy(token: String)
    case reinvest(token: String)
    case sell(token: String)
    case swap(token: String, toSymbol: String)
    case buyReferralAuthority(nick: String)
    case buySwapAuthority
    
    var description: String {
        switch self {
        case .buy: return "Buy"
        case .reinvest: return "Reinvest"
        case .sell: return "Sell"
        case .swap: return "Swap"
        case .withdraw: return "Withdraw"
        case .buyReferralAuthority: return "BuyReferralAuthority"
        case .buySwapAuthority: return "BuySwapAuthority"

        }
    }
}

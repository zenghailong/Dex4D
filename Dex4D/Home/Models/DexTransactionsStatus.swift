//
//  DexTransactionsStatus.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum Dex4DTransactionsType {
    case all
    case withdraw
    case buy
    case reinvest
    case sell
    case swap
}

extension Dex4DTransactionsType {
    
    var description: String {
        switch self {
        case .all: return "All"
        case .buy: return "Buy"
        case .reinvest: return "Reinvest"
        case .sell: return "Sell"
        case .swap: return "Swap"
        case .withdraw: return "Withdraw"
        }
    }
}

enum DexTransactionsStatus {
    case all
    case success
    case failed
    case pending
    
    var description: String {
        switch self {
        case .all: return "All"
        case .success: return "Success"
        case .failed: return "Failed"
        case .pending: return "Transaction.pending"
        }
    }
}

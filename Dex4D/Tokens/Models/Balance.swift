//
//  Balance.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/10.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

protocol BalanceProtocol {
    var value: BigInt { get }
    var amountShort: String { get }
    var amountFull: String { get }
}

struct Balance: BalanceProtocol {
    
    let value: BigInt
    
    init(value: BigInt) {
        self.value = value
    }
    
    var isZero: Bool {
        return value.isZero
    }
    
    var amountShort: String {
        return EtherNumberFormatter.short.string(from: value)
    }
    
    var amountFull: String {
        return EtherNumberFormatter.full.string(from: value)
    }
}

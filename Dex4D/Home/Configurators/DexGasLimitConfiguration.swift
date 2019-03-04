//
//  DexGasLimitConfiguration.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/30.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

public struct DexGasLimitConfiguration {
    
    static let `default` = BigInt("0x186a0".drop0x, radix: 16) ?? BigInt()
    
    static let approve = BigInt("0x186a0".drop0x, radix: 16) ?? BigInt()
    
    static func configurateContractGasLimit(type: Dex4DTradeType) -> BigInt {
        switch type {
        case .buy: return BigInt("0x55730".drop0x, radix: 16) ?? BigInt()
        case .reinvest: return BigInt("0x30d40".drop0x, radix: 16) ?? BigInt()
        case .sell: return BigInt("0x1adb0".drop0x, radix: 16) ?? BigInt()
        case .swap: return BigInt("0x668a0".drop0x, radix: 16) ?? BigInt()
        case .withdraw: return BigInt("0x19e10".drop0x, radix: 16) ?? BigInt()
        }
    }
}

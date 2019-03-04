//
//  Address+Extension.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/10.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum Errors: LocalizedError {
    case invalidAddress
    case invalidAmount
    case emptyToken
    case emptyAmount
    case balanceNotEnough
    case wrongInput
    
    var errorDescription: String? {
        switch self {
        case .invalidAddress:
            return "Invalid address".localized
        case .invalidAmount:
            return "Invalid amount".localized
        case .emptyToken:
            return "Please select token".localized
        case .emptyAmount:
            return "Please input amount".localized
        case .balanceNotEnough:
            return "Insufficient tokens".localized
        case .wrongInput:
            return "Wrong input".localized
        }
    }
}

extension EthereumAddress {
    static var zero: EthereumAddress {
        return EthereumAddress(string: "0x0000000000000000000000000000000000000000")!
    }
}

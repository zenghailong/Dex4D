//
//  ERC20Contract.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct ERC20Contract: Decodable {
    let address: String
    let name: String
    let totalSupply: String
    let decimals: Int
    let symbol: String
}

enum OperationType: String {
    case tokenTransfer = "token_transfer"
    case unknown
    
    init(string: String) {
        self = OperationType(rawValue: string) ?? .unknown
    }
}

extension OperationType: Decodable { }

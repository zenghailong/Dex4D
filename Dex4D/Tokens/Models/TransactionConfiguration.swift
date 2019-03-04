//
//  TransactionConfiguration.swift
//  Dex4D
//
//  Created by zeng hai long on 19/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

struct TransactionConfiguration {
    let gasPrice: BigInt
    let gasLimit: BigInt
    let data: Data
    let nonce: BigInt
}

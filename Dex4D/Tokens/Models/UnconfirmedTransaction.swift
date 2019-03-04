//
//  UnconfirmedTransaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

struct UnconfirmedTransaction {
    let transfer: Transfer
    let value: BigInt
    let to: EthereumAddress?
    let data: Data?
    
    let gasLimit: BigInt?
    let gasPrice: BigInt?
    let nonce: BigInt?
}

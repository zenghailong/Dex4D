//
//  DexUnconfirmedTransaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/8.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

import BigInt

struct DexUnconfirmedTransaction {
    let transfer: Dex4DTransfer
    let value: BigInt
    let to: EthereumAddress?
    let data: Data?
    
    let gasLimit: BigInt?
    let gasPrice: BigInt?
    let nonce: BigInt?
}

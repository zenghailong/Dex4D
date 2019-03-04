//
//  SignTransaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

public struct SignTransaction {
    let value: BigInt
    let account: Account
    let to: EthereumAddress?
    let nonce: BigInt
    let data: Data
    let gasPrice: BigInt
    let gasLimit: BigInt
    let chainID: Int
    
    // additinalData
    let localizedObject: LocalizedOperationObject?
}

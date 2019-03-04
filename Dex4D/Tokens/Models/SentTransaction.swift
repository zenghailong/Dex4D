//
//  SentTransaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct SentTransaction {
    let id: String
    let original: SignTransaction
    let data: Data
    let payType: PayMethod
}

extension SentTransaction {
    static func from(transaction: SentTransaction, txhash: String, token: TokenObject, sendValue: String) -> TransactionObject {
        return TransactionObject(
            txhash: txhash,
            blocknumber: 0,
            txindex: 0,
            from: transaction.original.account.address.description,
            to: transaction.original.to?.description ?? "",
            value: sendValue,
            gaslimit: transaction.original.gasLimit.description,
            gasprice: transaction.original.gasPrice.description,
            gasused: "", nonce: Int(transaction.original.nonce),
            timeStamp: String(Date.getCurrentTime()),
            symbol: token.symbol,
            status: TransactionState.pending.rawValue
        )
   }
}

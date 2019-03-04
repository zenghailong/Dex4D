//
//  ShowSendSuccessViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/22.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

struct ShowSendSuccessViewModel {
    
    let sentTransaction: SentTransaction
    let txHash: String
    let token: TokenObject
    let transfer: Transfer
    
    private let fullFormatter = EtherNumberFormatter.full
    
    var amount: String {
        switch transfer.type {
        case .ether, .dapp:
            let value = fullFormatter.string(from: sentTransaction.original.value, units: .ether)
            let originValue = value.replacingOccurrences(of: ",", with: "")
            return originValue.doubleValue.stringFloor6Value() + " " + token.symbol
        case .token(_):
            guard let value = sentTransaction.original.localizedObject?.value else {
               return "0"
            }
            let originValue = fullFormatter.string(from: BigInt(value) ?? BigInt(), decimals: token.decimals).replacingOccurrences(of: ",", with: "")
            return originValue.doubleValue.stringFloor6Value() + " " + token.symbol
        }
    }
    
    var gas: String {
        print(sentTransaction.original.gasLimit)
        print(sentTransaction.original.gasPrice)
        let gas = sentTransaction.original.gasLimit * sentTransaction.original.gasPrice
        return fullFormatter.string(from: gas, units: .ether)
    }
    
    var to: String {
        var toAddress: String?
        switch transfer.type {
        case .ether, .dapp: toAddress = sentTransaction.original.to?.description
        case .token(_): toAddress = sentTransaction.original.localizedObject?.to
        }
        guard  let to = toAddress  else {
            return ""
        }
        let front = to.substring(to: Config.ShowDecimals.addressFront)
        let back = to.substring(from: to.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var from: String {
        let address = sentTransaction.original.account.address.description
        let front = address.substring(to: Config.ShowDecimals.addressFront)
        let back = address.substring(from: address.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var txHashValue: String {
        let front = txHash.substring(to: 12)
        let back = txHash.substring(from: txHash.count - Config.ShowDecimals.addressFront)
        return front + "..." + back
    }
    
    init(
        sentTransaction: SentTransaction,
        txHash: String,
        token: TokenObject,
        transfer: Transfer
    ) {
        self.sentTransaction = sentTransaction
        self.txHash = txHash
        self.token = token
        self.transfer = transfer
    }

}

//
//  ConfirmSendViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/20.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

struct ConfirmSendViewModel {
    
    let configurator: TransactionConfigurator
    let account: Account
    let token: TokenObject
    
    private let fullFormatter = EtherNumberFormatter.full
    
    var amount: String {
        let value = fullFormatter.string(from: configurator.transaction.value, units: .ether)
        let originValue = value.replacingOccurrences(of: ",", with: "")
        return originValue.doubleValue.stringFloor6Value() + " " + token.symbol
    }
    
    var to: String {
        guard let toAddress = configurator.transaction.to else {
            return ""
        }
        let front = toAddress.description.substring(to: Config.ShowDecimals.addressFront)
        let back = toAddress.description.substring(from: toAddress.description.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var from: String {
        let address = account.address.description
        let front = address.substring(to: Config.ShowDecimals.addressFront)
        let back = address.substring(from: address.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var gas: String {
        print(configurator.configuration.gasLimit)
        print(configurator.configuration.gasPrice)
        let gas = configurator.configuration.gasLimit * configurator.configuration.gasPrice
        return fullFormatter.string(from: gas, units: .ether) + " ETH"
    }
    
    init(
        configurator: TransactionConfigurator,
        account: Account,
        token: TokenObject
    ) {
        self.configurator = configurator
        self.account = account
        self.token = token
    }
}

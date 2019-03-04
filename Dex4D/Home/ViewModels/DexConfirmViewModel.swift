//
//  DexConfirmViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/22.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct DexConfirmViewModel {
    
    let configurator: DexTransactionConfigurator
    let account: Account
    
    private let fullFormatter = EtherNumberFormatter.full
    
    var to: String {
        var toAddress = ""
        switch configurator.type {
        case .buyReferralAuthority, .buySwapAuthority: toAddress = DexConfig.dex_referraler
        default: toAddress = DexConfig.dex_protocol
        }
        let front = toAddress.description.substring(to: Config.ShowDecimals.addressFront)
        let back = toAddress.description.substring(from: toAddress.description.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var amountText: String {
        let value = fullFormatter.string(from: configurator.transaction.value, decimals: DexConfig.decimals)
        let amountValue = value.replacingOccurrences(of: ",", with: "")
        switch configurator.type {
        case .sell, .swap:
            return amountValue.doubleValue.stringFloor6Value() + " D4D"
        case .buy(let symbol), .reinvest(let symbol), .withdraw(let symbol):
            return amountValue.doubleValue.stringFloor6Value() + " " + symbol.uppercased()
        case .buyReferralAuthority, .buySwapAuthority:
            return amountValue.doubleValue.stringFloor6Value() + " ETH"
        }
    }
    
    var titleText: String {
        switch configurator.type {
        case .buy, .reinvest, .buyReferralAuthority, .buySwapAuthority:
            return "Send amount".localized
        case .sell, .swap:
            return "Sell amount".localized
        case .withdraw:
            return "Withdraw amount".localized
        }
    }
    
    var from: String {
        let address = account.address.description
        let front = address.substring(to: Config.ShowDecimals.addressFront)
        let back = address.substring(from: address.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var gas: String {
        let gas = configurator.configuration.gasLimit * configurator.configuration.gasPrice
        return fullFormatter.string(from: gas, decimals: DexConfig.decimals) + " ETH"
    }
    
    init(configurator: DexTransactionConfigurator) {
        self.configurator = configurator
        self.account = configurator.account
    }
    
    func getTxHashValue(txHash: String) -> String {
        let front = txHash.substring(to: Config.ShowDecimals.txHashFront)
        let back = txHash.substring(from: txHash.count - Config.ShowDecimals.txHashBack)
        return front + "..." + back
    }
    
    func sendCancelRequest(qrInfo: String) {
        let txData = ""
        let appName = qrInfo.qrStringAppName()
        let address = qrInfo.qrStringAddress()
        let nonce = qrInfo.qrStringNonce()
        let sign = [address, nonce, "false", txData].joined(separator: "&").md5String()
        
        ScanProvider.shared.qrPayConfirm(
            appname: appName,
            nonce: nonce,
            address: address,
            confirm: "false",
            txdata: txData,
            sign: sign
        ) { result in
            // TODO
        }
    }
}

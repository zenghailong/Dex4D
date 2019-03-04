//
//  ScanPaymentInfo.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/21.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt
import HandyJSON

struct ScanPaymentInfo: HandyJSON {
    var account = ""
    var amountA = ""
    var amountB = "0"
    var desc = ""
    var from = ""
    var gasLimit = ""
    var swapA = ""
    var swapB = ""
    var symbol = ""
    var to = ""
    var referrer = ""
    
    var inputGasLimit: BigInt {
        return BigInt(gasLimit.drop0x, radix: 16) ?? BigInt()
    }
    
    var transferActionType: D4DTransferActionType? {
        switch desc {
        case "buy":
            return D4DTransferActionType.buy(token: symbol)
        case "reinvest":
            return D4DTransferActionType.reinvest(token: symbol)
        case "sell":
            return D4DTransferActionType.sell(token: symbol)
        case "swap":
            return D4DTransferActionType.swap(token: swapA, toSymbol: swapB)
        case "buyReferralAuthority":
            return D4DTransferActionType.buyReferralAuthority(nick: referrer)
        case "buySwapAuthority":
            return D4DTransferActionType.buySwapAuthority
        case "withdraw":
            return D4DTransferActionType.withdraw(token: symbol)
        default:
            return nil
        }
    }
    
    var value: BigInt {
        return EtherNumberFormatter.full.number(from: amountA, decimals: DexConfig.decimals) ?? BigInt()
    }
    
    var amount: String {
        return amountB
    }
    
    var transfer: Dex4DTransfer {
        switch desc {
        case "buy":
            if symbol == "eth" {
                return Dex4DTransfer(server: RPCServer(), type: .ether)
            }
            return Dex4DTransfer(server: RPCServer(), type: .token)
        case "buyReferralAuthority", "buySwapAuthority":
            return Dex4DTransfer(server: RPCServer(), type: .ether)
        default:
            return Dex4DTransfer(server: RPCServer(), type: .token)
        }
    }
    
    func getTokenObject(tokens: [DexTokenObject]) -> DexTokenObject? {
        return tokens.filter { $0.name == symbol }.first
    }
    
    func getToAddress(token: DexTokenObject) -> EthereumAddress? {
        switch desc {
        case "buy":
            if symbol == "eth" {
                return EthereumAddress(string: to)
            }
            return EthereumAddress(string: token.token_addr)
        default:
            return EthereumAddress(string: to)
        }
    }
}

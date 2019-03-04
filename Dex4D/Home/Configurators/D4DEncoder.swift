//
//  D4DEncoder.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/26.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

enum EncodeTransferType {
    case buy(symbol: String, amount: BigUInt, referredBy: EthereumAddress)
    case sell(symbol: String, amount: BigUInt)
    case withdraw(symbol: String, amount: BigUInt)
    case reinvest(symbol: String, amount: BigUInt)
    case arbitrageTokens(fromSymbol: String, toSymbol: String, amount: BigUInt)
    case buyReferral(nick: String)
    case buyArbitrage
}

public final class D4DEncoder {
    /// Encodes a function call to `totalSupply`
    ///
    /// Solidity function: `function totalSupply() public constant returns (uint);`
    public static func encodeTotalSupply() -> Data {
        let function = Function(name: "totalSupply", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        return encoder.data
    }
    
    /// Encodes a function call to `name`
    ///
    /// Solidity function: `string public constant name = "Token Name";`
    public static func encodeName() -> Data {
        let function = Function(name: "name", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        return encoder.data
    }
    
    /// Encodes a function call to `symbol`
    ///
    /// Solidity function: `string public constant symbol = "SYM";`
    public static func encodeSymbol() -> Data {
        let function = Function(name: "symbol", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        return encoder.data
    }
    
    /// Encodes a function call to `decimals`
    ///
    /// Solidity function: `uint8 public constant decimals = 18;`
    public static func encodeDecimals() -> Data {
        let function = Function(name: "decimals", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        return encoder.data
    }
    
    /// Encodes a function call to `balanceOf`
    ///
    /// Solidity function: `function balanceOf(address tokenOwner) public constant returns (uint balance);`
    public static func encodeBalanceOf(address: EthereumAddress) -> Data {
        let function = Function(name: "balanceOf", parameters: [.address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [address])
        return encoder.data
    }
    
    /// Encodes a function call to `allowance`
    ///
    /// Solidity function: `function allowance(address tokenOwner, address spender) public constant returns (uint remaining);`
    public static func encodeAllowance(owner: EthereumAddress, spender: EthereumAddress) -> Data {
        let function = Function(name: "allowance", parameters: [.address, .address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [owner, spender])
        return encoder.data
    }
    
    /// Encodes a function call to `transfer`
    ///
    /// Solidity function: `function transfer(address to, uint tokens) public returns (bool success);`
    public static func encodeTransfer(to: EthereumAddress, tokens: BigUInt) -> Data {
        let function = Function(name: "transfer", parameters: [.address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [to, tokens])
        return encoder.data
    }
    
    /// Encodes a function call to `approve`
    ///
    /// Solidity function: `function approve(address spender, uint tokens) public returns (bool success);`
    /// spend: dealer address
    public static func encodeApprove(spender: EthereumAddress, tokens: BigUInt) -> Data {
        let function = Function(name: "approve", parameters: [.address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [spender, tokens])
        return encoder.data
    }
    
    /// Encodes a function call to `transferFrom`
    ///
    /// Solidity function: `function transferFrom(address from, address to, uint tokens) public returns (bool success);`
    public static func encodeTransfer(from: EthereumAddress, to: EthereumAddress, tokens: BigUInt) -> Data {
        let function = Function(name: "transferFrom", parameters: [.address, .address, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [from, to, tokens])
        return encoder.data
    }
    
    public static func encodeBuy(symbol: String, amount: BigUInt, referredBy: EthereumAddress) -> Data {
        let function = Function(name: "buy", parameters: [.string, .uint(bits: 256), .address])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [symbol, amount, referredBy])
        return encoder.data
    }
    
    public static func encodeSell(symbol: String, amount: BigUInt) -> Data {
        let function = Function(name: "sell", parameters: [.string, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [symbol, amount])
        return encoder.data
    }
    
    public static func encodeWithdraw(symbol: String, amount: BigUInt) -> Data {
        let function = Function(name: "withdraw", parameters: [.string, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [symbol, amount])
        return encoder.data
    }
    
    public static func encoderReinvest(symbol: String, amount: BigUInt) -> Data {
        let function = Function(name: "reinvest", parameters: [.string, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [symbol, amount])
        return encoder.data
    }
    
    public static func encodeArbitrageTokens(fromSymbol: String, toSymbol: String, amount: BigUInt) -> Data {
        let function = Function(name: "arbitrageTokens", parameters: [.string, .string, .uint(bits: 256)])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [fromSymbol, toSymbol, amount])
        return encoder.data
    }
    
    public static func encodeBuyReferral(nick: String) -> Data {
        let function = Function(name: "buyReferral", parameters: [.string])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [nick])
        return encoder.data
    }
    
    public static func encodeBuyArbitrage() -> Data {
        let function = Function(name: "buyArbitrage", parameters: [])
        let encoder = ABIEncoder()
        try! encoder.encode(function: function, arguments: [])
        return encoder.data
    }
    
    static func encodeDexOperation(type: EncodeTransferType) -> Data {
        switch type {
        case .buy(let symbol, let amount, let referredBy):
            return encodeBuy(symbol: symbol, amount: amount, referredBy: referredBy)
        case .sell(let symbol, let amount):
            return encodeSell(symbol: symbol, amount: amount)
        case .withdraw(let symbol, let amount):
            return encodeWithdraw(symbol: symbol, amount: amount)
        case .reinvest(let symbol, let amount):
            return encoderReinvest(symbol: symbol, amount: amount)
        case .arbitrageTokens(let fromSymbol, let toSymbol, let amount):
            return encodeArbitrageTokens(fromSymbol: fromSymbol, toSymbol: toSymbol, amount: amount)
        case .buyReferral(let nick):
            return encodeBuyReferral(nick: nick)
        case .buyArbitrage:
            return encodeBuyArbitrage()
        }
        
    }
}

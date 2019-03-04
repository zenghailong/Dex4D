//
//  Transaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/19.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift

enum TransactionState: Int {
    case completed = 1
    case pending
    case error
    case failed
    case unknown
    case deleted
    
    init(int: Int) {
        self = TransactionState(rawValue: int) ?? .unknown
    }
}

final class TransactionObject: Object, Decodable {
    @objc dynamic var txhash: String = ""
    @objc dynamic var blocknumber: Int = 0
    @objc dynamic var txindex: Int = 0
    @objc dynamic var from = ""
    @objc dynamic var to = ""
    @objc dynamic var value = ""
    @objc dynamic var gaslimit = ""
    @objc dynamic var gasprice = ""
    @objc dynamic var gasused = ""
    @objc dynamic var nonce: Int = 0
    @objc dynamic var timeStamp = ""
    @objc dynamic var status: Int = TransactionState.completed.rawValue
    @objc dynamic var symbol = ""
    convenience init(
        txhash: String,
        blocknumber: Int,
        txindex: Int,
        from: String,
        to: String,
        value: String,
        gaslimit: String,
        gasprice: String,
        gasused: String,
        nonce: Int,
        timeStamp: String,
        symbol: String,
        status: Int
    ) {
        self.init()
        self.txhash = txhash
        self.blocknumber = blocknumber
        self.txindex = txindex
        self.from = from
        self.to = to
        self.value = value
        self.gaslimit = gaslimit
        self.gasprice = gasprice
        self.gasused = gasused
        self.nonce = nonce
        self.timeStamp = timeStamp
        self.symbol = symbol
        self.status = status
    }
    
    private enum TransactionCodingKeys: String, CodingKey {
        case txhash
        case blocknumber
        case txindex
        case from
        case to
        case value
        case gaslimit
        case gasprice
        case gasused
        case nonce
        case timeStamp
        case symbol
        case status
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TransactionCodingKeys.self)
        let txhash = try container.decode(String.self, forKey: .txhash)
        let blockNumber = try container.decode(Int.self, forKey: .blocknumber)
        let txIndex = try container.decode(Int.self, forKey: .txindex)
        let from = try container.decode(String.self, forKey: .from)
        let to = try container.decode(String.self, forKey: .to)
        let value = try container.decode(String.self, forKey: .value)
        let gas = try container.decode(String.self, forKey: .gaslimit)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let gasPrice = try container.decode(String.self, forKey: .gasprice)
        let gasUsed = try container.decode(String.self, forKey: .gasused)
        let rawNonce = try container.decode(Int.self, forKey: .nonce)
        let timeStamp = try container.decode(String.self, forKey: .timeStamp)
        let status = try container.decode(Int.self, forKey: .status)
        guard
            let fromAddress = EthereumAddress(string: from) else {
                let context = DecodingError.Context(codingPath: [TransactionCodingKeys.from],
                                                    debugDescription: "Address can't be decoded as a TrustKeystore.Address")
                throw DecodingError.dataCorrupted(context)
        }
        
        self.init(
            txhash: txhash,
            blocknumber: blockNumber,
            txindex: txIndex,
            from: fromAddress.description,
            to: to,
            value: value,
            gaslimit: gas,
            gasprice: gasPrice,
            gasused: gasUsed,
            nonce: rawNonce,
            timeStamp: timeStamp,
            symbol: symbol,
            status: status
        )
    }
    
    override static func primaryKey() -> String? {
        return "txhash"
    }
    
    var state: TransactionState {
        return TransactionState(int: self.status)
    }
    
    var toAddress: EthereumAddress? {
        return EthereumAddress(string: to)
    }
    
    var fromAddress: EthereumAddress? {
        return EthereumAddress(string: from)
    }
    
}

//extension TransactionObject {
//    var operation: LocalizedOperationObject? {
//        return localizedOperations.first
//    }
//}

//
//  DexTransaction.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/9.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift
import HandyJSON

final class DexTransaction: Object, Decodable, HandyJSON {
    
    let titleFormmater: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
    
    @objc dynamic var id: String = ""
    @objc dynamic var type: String = ""
    @objc dynamic var denominated_balance: String = ""
    @objc dynamic var status: String = ""
    @objc dynamic var time: String = ""
    @objc dynamic var Tokens: String = ""
    @objc dynamic var basis_balance: String = ""
    @objc dynamic var price: String = ""
    
    convenience init(
        id: String,
        type: String,
        denominated_balance: String,
        status: String,
        time: String,
        Tokens: String,
        basis_balance: String,
        price: String
    ) {
        self.init()
        self.id = id
        self.type = type
        self.denominated_balance = denominated_balance
        self.status = status
        self.time = time
        self.Tokens = Tokens
        self.basis_balance = basis_balance
        self.price = price
    }
    
    private enum DexTransactionCodingKeys: String, CodingKey {
        case id = "_id"
        case type
        case denominated_balance
        case status
        case time
        case Tokens
        case basis_balance
        case price
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DexTransactionCodingKeys.self)
        let id = try container.decode(String.self, forKey: .id)
        let type = try container.decode(String.self, forKey: .type)
        let denominated_balance = try container.decode(String.self, forKey: .denominated_balance)
        let status = try container.decode(String.self, forKey: .status)
        let time = try container.decode(String.self, forKey: .time)
        let Tokens = try container.decode(String.self, forKey: .Tokens)
        let basis_balance = try container.decode(String.self, forKey: .basis_balance)
        let price = try container.decode(String.self, forKey: .price)
        
        self.init(
            id: id,
            type: type,
            denominated_balance: denominated_balance,
            status: status,
            time: time,
            Tokens: Tokens,
            basis_balance: basis_balance,
            price: price
        )
    }
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    var state: String {
        return status
    }
    
    var formatterTime: String {
        let timeInterval: TimeInterval = TimeInterval(self.time) ?? 0
        let date = Date(timeIntervalSince1970: timeInterval)
        return titleFormmater.string(from: date)
    }
    
    var txHashValue: String {
        let front = id.substring(to: Config.ShowDecimals.addressFront)
        let back = id.substring(from: id.count - Config.ShowDecimals.addressBack)
        return front + "..." + back
    }
    
    var assetPairs: String {
        if Tokens.contains("/") {
            let parts = Tokens.components(separatedBy: "/")
            if let lastPart = parts.last, let firstPart = parts.first {
                guard firstPart == "Dex4D" else {
                    return firstPart.uppercased() + "/" + lastPart.uppercased()
                }
                return firstPart + "/" + lastPart.uppercased()
            }
        }
        return Tokens
    }
}

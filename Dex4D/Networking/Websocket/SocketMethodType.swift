//
//  SocketMethodType.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum SocketMethodType {
    case getMarketcap(id: String, method: String)
    case getPool(id: String, method: String)
    case personTradingList(method: String)
}

enum SocketRecieveTag: String {
    case marketcap = "getDetails"
    case getPool = "getPool"
    case personTradingList = "personTradingList"
}

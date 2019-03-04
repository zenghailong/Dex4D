//
//  WebSocketService.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct WebSocketService {
    /**
     *  Method getDetail
     *  @param
     *  @param
     */
    static func getDexTokenDetail() {
        WebSocketProvider.shared.sendRequest(type: .getMarketcap(id:  "getDetails", method: "marketcap_subscribe"), params: ["getDetails"])
    }
    
    /// get personal trading list
    static func getPersonTradingList(account: String) {
        WebSocketProvider.shared.sendRequest(type: .personTradingList(method: "kline_subscribe"), params: ["personTradingList", account])
    }
    
}

//
//  WebSocketProvider.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Starscream
import SwiftyJSON
import HandyJSON

final class WebSocketProvider {
    
    class var shared: WebSocketProvider {
        struct Static {
            static let instance: WebSocketProvider = WebSocketProvider()
        }
        return Static.instance
    }
    
    let socket: WebSocket = {
        return WebSocket(url: URL(string: DexConfig.websocketBaseUrl)!)
    }()
    
    public var isConnected: Bool = false
    
    var getDexDetailBlock: (([DexMarketcap]) -> Swift.Void)?
    
    var getTransactionBlock: (([DexTransaction]) -> Swift.Void)?
    
    var connectCount = 0
}

extension WebSocketProvider {
    func webSocketOpen() {
        if isConnected == false {
            socket.delegate = self
            socket.connect()
            connectCount += 1
        }
    }
    
    func webSocketClose() {
       socket.disconnect()
    }
    
    func sendRequest(type: SocketMethodType, params: [String]) {
        var requestParameters: [String: Any] = [:]
        switch type {
        case .getMarketcap(let id, let method):
            requestParameters["id"] = id
            requestParameters["method"] = method
            requestParameters["params"] = params
        case .personTradingList(let method):
            requestParameters["id"] = 1
            requestParameters["method"] = method
            requestParameters["params"] = params
        case .getPool: break
        }
        let json: JSON = JSON(requestParameters)
        socket.write(string: "\(json)")
    }
}

extension WebSocketProvider: WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
        isConnected = true
        connectCount = 0
        NotificationCenter.default.post(name: NotificationNames.websocketConnected, object: nil)
        DebugLogger.log(item: "websocket connected")
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        isConnected = false
        guard connectCount < 5 else {
            return
        }
        socket.connect()
        DebugLogger.log(item: "websocket is disconnected: \(String(describing: error?.localizedDescription))")
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        DebugLogger.log(item: "got some data: \(data.count)")
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        let json = JSON(parseJSON: text)
        let tag = json["tag"].stringValue
        switch tag {
        case SocketRecieveTag.marketcap.rawValue:
            if let results = json["params"]["result"].array {
                var detailList: [DexMarketcap] = []
                results.forEach { json in
                    if let jsonObject = json.dictionaryObject, let model = DexMarketcap.deserialize(from: jsonObject) {
                        detailList.append(model)
                    }
                }
                getDexDetailBlock?(detailList)
            }
        case SocketRecieveTag.personTradingList.rawValue:
            if let results = json["params"]["result"].array {
                var transactionList: [DexTransaction] = []
                results.forEach { json in
                    if let jsonObject = json.dictionaryObject, let model = DexTransaction.deserialize(from: jsonObject) {
                        transactionList.append(model)
                    }
                }
                getTransactionBlock?(transactionList)
            }
        case SocketRecieveTag.getPool.rawValue:
            break
        default:
            break
        }
    }
    
}

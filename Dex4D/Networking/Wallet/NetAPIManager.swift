//
//  NetAPIManager.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Moya

enum NetAPIManager {
    /// get etherum balance
    case getEtherBalance(id: Int, jsonrpc: String, method: String, params: [Any])
    /// get ERC20 token balance
    case getERC20Balance(id: Int, jsonrpc: String, method: String, params: [Any])
    /// get gasPrice
    case getGasPrice(id: Int, jsonrpc: String, method: String, params: [Any])
    /// getNonce
    case getNonce(id: Int, jsonrpc: String, method: String, params: [Any])
    /// getEstimateGas
    case getEstimateGas(id: Int, jsonrpc: String, method: String, params: [Any])
    /// send transaction
    case send(id: Int, jsonrpc: String, method: String, params: [Any])
    case getTokensPrice(coins: [String], currency: String)
    case addTransactionObject(parameters: [String: Any])
    case getTxInfo(txhashes: [String])
}

extension NetAPIManager: TargetType {
    var path: String {
        switch self {
        case .addTransactionObject: return "/addtx"
        case .getTxInfo: return "gettxinfo"
        default: return ""
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return "{}".data(using: String.Encoding.utf8)!
    }
    
    var task: Task {
        switch self {
        case let .getEtherBalance(id, jsonrpc, method, params),
             let .getERC20Balance(id, jsonrpc, method, params),
             let .getGasPrice(id, jsonrpc, method, params),
             let .getNonce(id, jsonrpc, method, params),
             let .getEstimateGas(id, jsonrpc, method, params),
             let .send(id, jsonrpc, method, params):
            return .requestParameters(parameters: ["id": id, "jsonrpc": jsonrpc, "method": method, "params": params], encoding: JSONEncoding.default)
        case .getTokensPrice(let coins, let currency):
            var paramsDict: [String : Any] = ["id": 1, "jsonrpc": "2.0"]
            paramsDict["method"] = "gateway_getMarketPrice"
            paramsDict["params"] = [currency, coins]
            return .requestParameters(parameters: paramsDict, encoding: JSONEncoding.default)
        case .addTransactionObject(let parameters):
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
        case .getTxInfo(let txhashes):
            return .requestParameters(parameters: ["txhashes": txhashes], encoding: JSONEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json"]
    }
    
    var baseURL: URL {
        switch self {
        case .addTransactionObject, .getTxInfo: return URL(string: Dex4DUrls.tokenTransactionBase)!
        default: return URL(string: Dex4DUrls.httpServerBase)!
        }
    }
    
    var parameterEncoding: ParameterEncoding {//编码的格式
        return URLEncoding.default
    }
    
    var show: Bool { //是否显示转圈提示
        return true
    }
}

//
//  RPCServer.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/18.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import Moya

enum Dex4DServer {
    /// getTokenList
    case getTokenList()
    /// 买卖价格、池子剩余量
    case getDex4DPoolInfo(coin: String)
    // 获取保险箱信息
    case getDex4DBalance(address: String, currency: String)
    case getDex4DCountWithCoin(coin: String, count: String)
    case getSpendTokenByBuyDex4D(coin: String, count: String)
    case hasDex4DReferralAuthority(address: String)
    case hasDex4DSwapAuthority(address: String)
    case getCoinCountBySellDex4D(coin: String, count: String)
    case getDex4DGasPrice()
    case getDex4DReferralUserName(address: String)
    case getDex4DReferralAddress(username: String)
    case isStandardDex4DUserName(username: String)
    case getEthCountByDex4DOperation(operation: String)
    case sendDex4DTranstion(data: String)
    case getDex4DNonce(address: String)
    case getGames(name: String)
    /// 写入操作日志
    case writeLog(input: Dictionary<String, Any>)
    case loginLog(address: String, type: String, udid: String, device: String, osVersion: String)
}

extension Dex4DServer: TargetType {
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: Dex4DUrls.httpServerBase)!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        switch self {
        default:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        var paramsDict: [String : Any] = ["id": 1, "jsonrpc": "2.0"]
        switch self {
        case .getDex4DPoolInfo(let coin):
            paramsDict["method"] = "marketcap_getMarketCapInfo"
            paramsDict["params"] = [coin]
        case .getDex4DBalance(let address, let currency):
            paramsDict["method"] = "gateway_vaultOverview"
            paramsDict["params"] = [["account": address, "legealName": currency]]
        case .getDex4DCountWithCoin(let coin, let count):
            paramsDict["method"] = "contractservice_calculateTokensReceived"
            paramsDict["params"] = [coin, count]
        case .getSpendTokenByBuyDex4D(let coin, let count):
            paramsDict["method"] = "contractservice_calculateBuyTokenSpend"
            paramsDict["params"] = [coin, count]
        case .getCoinCountBySellDex4D(let coin, let count):
            paramsDict["method"] = "contractservice_calculateBuyTokenReceived"
            paramsDict["params"] = [coin, count]
        case .hasDex4DReferralAuthority(let address):
            paramsDict["method"] = "contractservice_isReferraler"
            paramsDict["params"] = [address]
        case .hasDex4DSwapAuthority(let address):
            paramsDict["method"] = "contractservice_isArbitrager"
            paramsDict["params"] = [address]
        case .getDex4DGasPrice():
            paramsDict["method"] = "contractservice_gasPrice"
            paramsDict["params"] = []
        case .getDex4DReferralUserName(let address):
            paramsDict["method"] = "contractservice_getName"
            paramsDict["params"] = [address]
        case .getDex4DReferralAddress(let username):
            paramsDict["method"] = "contractservice_getAddress"
            paramsDict["params"] = [username]
        case .isStandardDex4DUserName(let username):
            paramsDict["method"] = "contractservice_checkName"
            paramsDict["params"] = [username]
        case .getEthCountByDex4DOperation(let operation):
            paramsDict["method"] = "kline_getPayment"
            paramsDict["params"] = [operation]
        case .sendDex4DTranstion(let data):
            paramsDict["method"] = "contractservice_sendRawTransaction"
            paramsDict["params"] = [data]
        case .getDex4DNonce(let address):
            paramsDict["method"] = "contractservice_getNonce"
            paramsDict["params"] = [address]
        case .getTokenList:
            paramsDict["method"] = "gateway_getTokenTables"
            paramsDict["params"] = []
        case .getGames(let name):
            paramsDict["method"] = "gateway_getGamesByTokenName"
            paramsDict["params"] = [name]
        case .writeLog(let inputs):
            paramsDict["method"] = "gateway_writeLog"
            paramsDict["params"] = [inputs]
        case .loginLog(let address, let type, let udid, let device, let osVersion):
            paramsDict["method"] = "gateway_loginInfo"
            paramsDict["params"] = [[
                "user_addr" : address,
                "login_type" : type,
                "device_type" : "iOS",
                "device_id" : udid,
                "device_version" : device,
                "os_version" : osVersion
            ]]
        }
        return paramsDict
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        return .requestParameters(parameters: parameters ?? [:], encoding: JSONEncoding.default)
    }
    
}

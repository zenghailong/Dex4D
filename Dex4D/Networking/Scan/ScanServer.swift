//
//  ScanServer.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/13.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import Moya

enum ScanServer {
    case qrLogin(appname: String, nonce: String, address: String)
    case qrLoginConfirm(appname: String, nonce: String, address: String, confirm: String)
    case qrPayInfo(appname: String, nonce: String, address: String, sign: String)
    case qrPayConfirm(appname: String, nonce: String, address: String, confirm: String, txdata: String, sign: String)
}

extension ScanServer: TargetType {
    
    var headers: [String : String]? {
        return ["Content-type" : "application/json"]
    }
    
    var baseURL: URL {
        return URL(string: Dex4DUrls.scanServerBase)!
    }
    
    var path: String {
        switch self {
        case .qrLogin(_):
            return "/qrlogin"
        case .qrLoginConfirm(_):
            return "/qrconfirm"
        case .qrPayInfo(_):
            return "/qrpay_info"
        case .qrPayConfirm(_):
            return "/qrpay_confirm"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .qrLogin(_), .qrPayInfo(_):
            return .get
        default:
            return .post
        }
    }
    
    var parameters: [String: Any]? {
        var paramsDict: [String : Any] = [:]
        switch self {
        case .qrLogin(let appname, let nonce, let address):
            paramsDict["appname"] = appname
            paramsDict["nonce"] = nonce
            paramsDict["address"] = address
        case .qrLoginConfirm(let appname, let nonce, let address, let confirm):
            paramsDict["appname"] = appname
            paramsDict["nonce"] = nonce
            paramsDict["address"] = address
            paramsDict["confirm"] = confirm
        case .qrPayInfo(let appname, let nonce, let address, let sign):
            paramsDict["appname"] = appname
            paramsDict["nonce"] = nonce
            paramsDict["address"] = address
            paramsDict["sign"] = sign
        case .qrPayConfirm(let appname, let nonce, let address, let confirm, let txdata, let sign):
            paramsDict["appname"] = appname
            paramsDict["nonce"] = nonce
            paramsDict["address"] = address
            paramsDict["confirm"] = confirm
            paramsDict["txdata"] = txdata
            paramsDict["sign"] = sign
        }
        print(baseURL)
        print(paramsDict)
        return paramsDict
    }
    
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case .qrLogin(_), .qrPayInfo(_):
            return .requestParameters(parameters: parameters ?? [:], encoding: URLEncoding.default)
        default:
            return .requestParameters(parameters: parameters ?? [:], encoding: JSONEncoding.default)
        }
    }
    
}

//
//  NetServiceProvider.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/12.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

import Moya

typealias SuccessClosure = (_ result: Dictionary<String, Any>) -> Void
typealias FailureClosure = (_ error: MoyaError) -> Void

let requestClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<NetAPIManager>.RequestResultClosure) in
    
    do {
        var request: URLRequest = try endpoint.urlRequest()
        request.timeoutInterval = 30
        done(.success(request))
    } catch  {
        print("\(error)")
    }
}

/// MARK: - 自定义的网络提示请求插件
let myNetworkPlugin = MyNetworkActivityPlugin { (state,target) in
    
    let api = target as! NetAPIManager
    
    if state == .began {
        if api.show {
            
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    } else if state == .ended {
        if api.show {
            
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}

let provider = MoyaProvider<NetAPIManager>(requestClosure: requestClosure, plugins: [myNetworkPlugin])


func JSONResponseFormatter(_ data: Data) -> Dictionary<String, Any>? {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        return dataAsJSON as? Dictionary<String, Any>
    } catch {
        return nil // fallback to original data if it can't be serialized.
    }
}

enum NetRequestError: LocalizedError {
    
    case failedRequestToGetBalance
    case failedRequestForGasPrice
    
    var errorDescription: String? {
        switch self {
        case .failedRequestToGetBalance:
            return "Failed to get token balance"
        case .failedRequestForGasPrice:
            return "Failed to get gasPrice"
        }
    }
}

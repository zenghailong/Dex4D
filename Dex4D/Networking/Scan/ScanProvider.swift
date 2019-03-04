//
//  ScanProvider.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/13.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON

let scanPayError = [
    "0": "No error".localized,
    "1": "Unknow error".localized,
    "2": "Duplicate nonce".localized,
    "3": "Create nonce failed".localized,
    "4": "The nonce has been bound".localized,
    "5": "Address mismatched".localized,
    "6": "QR code timeout".localized,
    "7": "Address form error".localized,
    "8": "Sign verify failed".localized,
    "9": "Nonce not exist".localized,
    "10": "This transcation already finished".localized,
    "11": "Code state error".localized,
    "12": "Send transaction failed".localized]
    

let scanClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<ScanServer>.RequestResultClosure) in
    do {
        var request: URLRequest = try endpoint.urlRequest()
        request.timeoutInterval = 30
        done(.success(request))
    } catch  {
        print("\(error)")
    }
}

class ScanProvider {
    
    static let shared = ScanProvider()

    let dex4DProvider = MoyaProvider<ScanServer>(requestClosure: scanClosure, plugins: [networkPlugin])
    
    private func failureAction(error: Dex4DProviderError) {
        if NetworkingManager.status == .none || NetworkingManager.status == .unknown {
            Toast.showMessage(message: NetworkingManager.status.description)
        } else {
            Toast.showMessage(message: error.description)
        }
    }
    
    func qrLogin(appname: String,
                 nonce: String,
                 address: String,
                 completion: @escaping (Result<Bool, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.qrLogin(
            appname: appname,
            nonce: nonce,
            address: address)) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data) {
                    print(response)
                    if let status = response["state"] as? Int {
                        completion(.success(status == 1 ? true : false))
                    }
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func qrLoginConfirm(appname: String,
                        nonce: String,
                        address: String,
                        confirm: String,
                        completion: @escaping (Result<Bool, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.qrLoginConfirm(
            appname: appname,
            nonce: nonce,
            address: address,
            confirm: confirm)) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data) {
                    print(response)
                    if let status = response["state"] as? Int {
                        completion(.success(status == 1 ? true : false))
                    }
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    func qrPayInfo(appname: String,
                   nonce: String,
                   address: String,
                   sign: String,
                   completion: @escaping (Result<ScanPaymentInfo, Dex4DProviderError>) -> Void
    ) {
        dex4DProvider.request(.qrPayInfo(
            appname: appname,
            nonce: nonce,
            address: address,
            sign: sign)) { result in
                switch result {
                case .success(let responseData):
                    if let response = JSONResponseFormatter(responseData.data),
                        self.checkPayInfo(response: response),
                        let data = response["paydata"] as?  Dictionary<String, String>,
                        let payData = ScanPaymentInfo.deserialize(from: data) {
                        completion(.success(payData))
                    } else {
                        completion(.failure(.data))
                    }
                case .failure(_):
                    self.failureAction(error: .server)
                    completion(.failure(.server))
                }
        }
    }
    
    private func checkPayInfo(response: Dictionary<String, Any>) -> Bool {
      
        guard let data = response["paydata"] as?  Dictionary<String, String>, let sign = response["sign"] as? String else {
            return false
        }
        guard
            let desc = data["desc"],
            let symbol = data["symbol"],
            let swapA = data["swapA"],
            let swapB = data["swapB"],
            let amountA = data["amountA"],
            let amountB = data["amountB"],
            let gasLimit = data["gasLimit"],
            let account = data["account"],
            let from = data["from"],
            let to = data["to"],
            let referrer = data["referrer"]
        else {
            return false
        }
        let str = [desc, symbol, swapA, swapB, amountA, amountB, gasLimit, account, from, to, referrer].joined(separator: "&")
        if str.md5String() == sign {
            return true
        }
        return false
    }
    
    func qrPayConfirm(appname: String,
                      nonce: String,
                      address: String,
                      confirm: String,
                      txdata: String,
                      sign: String,
                      completion: @escaping (Result<[String: Any], Dex4DProviderError>) -> Void
    ) {
        dex4DProvider.request(.qrPayConfirm(
            appname: appname,
            nonce: nonce,
            address: address,
            confirm: confirm,
            txdata: txdata,
            sign: sign)) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data) {
                    print(response)
                    if let _ = response["state"] as? Int {
                        completion(.success(response))
                    }
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
}


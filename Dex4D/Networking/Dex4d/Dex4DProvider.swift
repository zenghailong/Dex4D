//
//  Dex4DProvider.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/18.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import Moya
import Result
import SwiftyJSON
import BigInt

let networkPlugin = NetworkActivityPlugin { (change, _) in
    switch(change){
    case .ended:
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    case .began:
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
}

enum Dex4DProviderError: LocalizedError {
    case server
    case data
    case message(msg: String)
    
    var description: String {
        switch self {
        case .server:
            return "Failed to connect to server".localized
        case .data:
            return "Failed to get data".localized
        case .message(let msg):
            return msg
        }
    }
}

let requestDexClosure = { (endpoint: Endpoint, done: @escaping MoyaProvider<Dex4DServer>.RequestResultClosure) in
    do {
        var request: URLRequest = try endpoint.urlRequest()
        request.timeoutInterval = 30
        done(.success(request))
    } catch  {
        print("\(error)")
    }
}

class Dex4DProvider {
    
    static let shared = Dex4DProvider()
    
    private func failureAction(error: Dex4DProviderError) {
        if NetworkingManager.status == .none || NetworkingManager.status == .unknown {
            Toast.showMessage(message: NetworkingManager.status.description)
        } else {
            Toast.showMessage(message: error.description)
        }
    }
    
    let dex4DProvider = MoyaProvider<Dex4DServer>(requestClosure: requestDexClosure, plugins: [networkPlugin])
    /// Get token list from service
    func getAllTokens(completion: @escaping (Result<[[String: Any]], Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getTokenList()) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data), let tokenObjects = response["result"] as? [[String: Any]] {
                    completion(.success(tokenObjects))
                } else {
                    completion(.failure(.data))
                }
            case .failure(_):
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DPoolMarketInfo(coin: String, completion: @escaping (Result<DexPoolMarketInfo, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DPoolInfo(coin: coin)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let dexPoolMarketInfo = DexPoolMarketInfo.deserialize(from: json["result"]["data"].dictionary) {
                        completion(.success(dexPoolMarketInfo))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DBalance(address: String, currency: Currency = LocalizationTool.shared.currentCurrency, completion: @escaping (Result<[String: Any], Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DBalance(address: address, currency: DexConfig.current.currency)) { result in
            switch result {
            case let .success(responseData):
                if let response = JSONResponseFormatter(responseData.data), let accountInfo = response["result"] as? [String: Any] {
                    completion(.success(accountInfo))
                } else {
                    completion(.failure(.data))
                }
            case .failure(_):
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DCount(by coin: String, tokenCount: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DCountWithCoin(coin: coin, count: tokenCount)) { result in
            switch result {
            case let .success(responseData):
                if let response = JSONResponseFormatter(responseData.data), let value = response["result"] as? String, let count = BigInt(value.drop0x, radix: 16)  {
                    let countStr = EtherNumberFormatter.short.string(from: count, units: .ether)
                    completion(.success(countStr))
                } else {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getSpendTokenCountByBuyDex4D(coin: String, count: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getSpendTokenByBuyDex4D(coin: coin, count: count)) { result in
            switch result {
            case let .success(responseData):
                if let response = JSONResponseFormatter(responseData.data), let value = response["result"] as? String, let count = BigInt(value.drop0x, radix: 16)  {
                    let countStr = EtherNumberFormatter.short.string(from: count, units: .ether)
                    completion(.success(countStr))
                } else {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getCoinCountSellDex4D(coin: String, count: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getCoinCountBySellDex4D(coin: coin, count: count)) { result in
            switch result {
            case let .success(responseData):
                if let response = JSONResponseFormatter(responseData.data), let value = response["result"] as? String, let tokenCount = BigInt(value.drop0x, radix: 16)  {
                    let countStr = EtherNumberFormatter.short.string(from: tokenCount, units: .ether)
                    completion(.success(countStr))
                } else {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func hasDex4DReferralAuthority(address: String, completion: @escaping (Result<Int, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.hasDex4DReferralAuthority(address: address)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].int {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func hasDex4DSwapAuthority(address: String, completion: @escaping (Result<Int, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.hasDex4DSwapAuthority(address: address)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].int {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DGasPrice(completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DGasPrice()) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].string {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DReferralUserName(address: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DReferralUserName(address: address)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].string {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DReferralAddress(username: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DReferralAddress(username: username)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].string {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func isStandardDex4DUserName(username: String, completion: @escaping (Result<Bool, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.isStandardDex4DUserName(username: username)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    print(json)
                    if let data = json["result"].bool {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getEthCountByDex4DOperation(operation: AuthorityOperation.Operation, completion: @escaping (Result<Double, Dex4DProviderError>) -> Void) {
        let str = operation == .referral ? "referrals" : "swap"
        dex4DProvider.request(.getEthCountByDex4DOperation(operation: str)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"]["payment"].double {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func sendDex4DTranstion(data: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.sendDex4DTranstion(data: data)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    print(json)
                    if let data = json["error"]["message"].string {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getDex4DNonce(address: String, completion: @escaping (Result<String, Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getDex4DNonce(address: address)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let data = json["result"].string {
                        completion(.success(data))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func getGames(name: String, completion: @escaping (Result<[Dex4DGame], Dex4DProviderError>) -> Void) {
        dex4DProvider.request(.getGames(name: name)) { result in
            switch result {
            case let .success(response):
                do {
                    let json = try JSON(data: response.data)
                    if let arr = json["result"].array {
                        var games: [Dex4DGame] = []
                        arr.forEach({ (json) in
                            if let game = Dex4DGame.deserialize(from: json.dictionary) {
                                games.append(game)
                            }
                        })
                        completion(.success(games))
                    }
                } catch {
                    self.failureAction(error: .data)
                    completion(.failure(.data))
                }
            case .failure(_):
                self.failureAction(error: .server)
                completion(.failure(.server))
            }
        }
    }
    
    func writeActionLog(input: Dictionary<String, Any>) {
        dex4DProvider.request(.writeLog(input: input)) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data) {
                  print(response)
                }
            case .failure(_):
                break
            }
        }
    }
    
    func loginLog(address: String, type: String) {
        let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let device = UIDevice.current.deviceType
        let osVersion = UIDevice.current.systemVersion
        dex4DProvider.request(.loginLog(address: address, type: type, udid: udid, device: device, osVersion: osVersion)) { result in
            switch result {
            case .success(let responseData):
                if let response = JSONResponseFormatter(responseData.data) {
                    print(response)
                }
            case .failure(_):
                break
            }
        }
    }
    
}

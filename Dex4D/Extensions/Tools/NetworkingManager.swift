//
//  NetworkReachabilityManager.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/15.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Alamofire

enum NetworkingStatus {
    case mobile
    case wifi
    case none
    case unknown
    var description: String {
        switch self {
        case .mobile:
            return "Connected cellular mobile network".localized
        case .wifi:
            return "Connected WIFI".localized
        case .none:
            return "Network not connected".localized
        case .unknown:
            return "Unknown network".localized
        }
    }
}

class NetworkingManager {
    
    static var isFirst = true
    static var oldStatus: NetworkingStatus = .unknown
    static var status: NetworkingStatus = .unknown
    
    class func startListenNetwork() {
        let manager = NetworkReachabilityManager()
        manager?.listener = { status in
            self.oldStatus = self.status
            switch status {
            case .unknown:
                self.status = .unknown
            case .notReachable:
                self.status = .none
            case .reachable:
                if manager?.isReachableOnWWAN ?? false {
                    self.status = .mobile
                } else if manager?.isReachableOnEthernetOrWiFi ?? false {
                    self.status = .wifi
                }
            }
            if isFirst {
                isFirst = false
            } else {
                Toast.showMessage(message: self.status.description)
                if oldStatus == .none || oldStatus == .unknown, self.status == .mobile || self.status == .wifi {
                    NotificationCenter.default.post(name: NotificationNames.getNetworking, object: nil)
                }
                if oldStatus == .mobile || oldStatus == .wifi, self.status == .none {
                    NotificationCenter.default.post(name: NotificationNames.loseNetworking, object: nil)
                }
            }
            print("networing == ", self.status.description)
        }
        manager?.startListening()
    }
    
}

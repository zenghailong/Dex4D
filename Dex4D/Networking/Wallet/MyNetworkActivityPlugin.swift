//
//  MyNetworkActivityPlugin.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Moya
import Result

/// Network activity change notification type.
public enum MyNetworkActivityChangeType {
    case began, ended
}

/// Notify a request's network activity changes (request begins or ends).
public final class MyNetworkActivityPlugin: PluginType {
    
    
    
    public typealias MyNetworkActivityClosure = (_ change: MyNetworkActivityChangeType, _ target: TargetType) -> Void
    let myNetworkActivityClosure: MyNetworkActivityClosure
    
    public init(newNetworkActivityClosure: @escaping MyNetworkActivityClosure) {
        self.myNetworkActivityClosure = newNetworkActivityClosure
    }
    
    // MARK: Plugin
    
    /// Called by the provider as soon as the request is about to start
    public func willSend(_ request: RequestType, target: TargetType) {
        DispatchQueue.main.async {
           self.myNetworkActivityClosure(.began,target)
        }
        
    }
    
    /// Called by the provider as soon as a response arrives, even if the request is cancelled.
    public func didReceive(_ result: Result<Moya.Response, MoyaError>, target: TargetType) {
        DispatchQueue.main.async {
            self.myNetworkActivityClosure(.ended,target)
        }
    }
        
}

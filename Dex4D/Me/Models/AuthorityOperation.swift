//
//  AuthorityOperation.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/5.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

struct AuthorityOperation {
    
    enum Operation {
        case referral
        case swap
    }
    
    enum Authority {
        case forever
        case pending
        case temp
        case none
        case unknow
    }
    
    var operation: Operation
    var authority: Authority
    
    var stringValue: String {
        switch operation {
        case .referral:
            return "referral"
        case .swap:
            return "swap"
        }
    }
    
    var dex4DCount: Double {
        switch operation {
        case .referral:
            return 500
        case .swap:
            return 1000
        }
    }
    
    init(operation: Operation, authority: Authority = .unknow) {
        self.operation = operation
        self.authority = authority
    }
    
}


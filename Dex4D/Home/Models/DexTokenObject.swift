//
//  DexTokenObject.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/23.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import HandyJSON

enum TokenState: Int {
    case advisor = 0, new, regular, sunDown, delist
}

extension TokenState {
    var descripton: String {
        switch self {
        case .advisor: return "Advisor"
        case .new: return "New"
        case .regular: return "Regular"
        case .sunDown: return "SunDown"
        case .delist: return "Delist"
        }
    }
    
    var colorString: String {
        switch self {
        case .advisor: return "59b884"
        case .new: return "fdd765"
        case .regular: return "ffffff"
        case .sunDown: return "ec4c5c"
        case .delist: return "ec4c5c"
        }
    }
}

struct DexTokenObject: HandyJSON {
    
    static let DEFAULT_ID = 1
    static let DEFAULT_STATE = 1
    
    var token_id: Int = DEFAULT_ID
    var name: String = ""
    var token_addr: String = ""
    var dealer_addr: String = ""
    var state: Int = DEFAULT_STATE
    var market_token: String = ""
    var icon_app: String = ""
    var ambassador_end: String = ""
    var ambassador_begin: String = ""
    var offline_time: String = ""
    
    var tokenState: TokenState {
        return TokenState(rawValue: state) ?? .regular
    }
}


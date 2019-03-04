////
////  Dex4DInfo.swift
////  Dex4D
////
////  Created by ColdChains on 2018/10/18.
////  Copyright © 2018 龙. All rights reserved.
////
//
import Foundation
import SwiftyJSON
import HandyJSON

struct DexPoolMarketInfo: HandyJSON {
    var buy_price: String = ""
    var sell_price: String = ""
    var total_supply: String = ""
    var total_tokens: String = ""
    var block: Int64 = 0
}

//
//  Dex4DGame.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/13.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation
import SwiftyJSON
import HandyJSON

struct Dex4DGame: HandyJSON {
    var token_id: Int64 = 0
    var token_name: String = ""
    var game_name_en: String = ""
    var game_name_ch: String = ""
    var desc_en: String = ""
    var desc_ch: String = ""
    var address: String = ""
    var logo: String = ""
    var background: String = ""
    var state: Int8 = 0
    var create_time: Int64 = 0
    var publish_time: Int64 = 0
    var offline_time: Int64 = 0
}

//
//  Currencyt.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/31.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

extension Currency {
    func symbol() -> String {
        return self == .CNY ? "￥" : "$"
    }
    func string() -> String {
        return self == .CNY ? "CNY" : "USD"
    }
}

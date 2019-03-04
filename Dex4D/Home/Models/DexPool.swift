//
//  DexPool.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/24.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

public struct DexPool {
    
    let tokenId: Int
    let tokenName: String
    var coin: Double?
    var coinLegeal: Double?
    var d4dCount: Double?
    var d4dPrice: Double?
    var revenue: Double?
    var revenueLegeal: Double?
    var rebateFeelets: Double?
    var rebateFeesLegeal: Double?
    var dividends: Double?
    var dividendsLegeal: Double?
    
    var games: [Dex4DGame] = []
    
}

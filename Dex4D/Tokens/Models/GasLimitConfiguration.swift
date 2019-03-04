//
//  GasLimitConfiguration.swift
//  Dex4D
//
//  Created by zeng hai long on 19/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

public struct GasLimitConfiguration {
    static let `default` = BigInt(90_000)
    static let min = BigInt(21_000)
    static let max = BigInt(600_000)
    static let tokenTransfer = BigInt(144_000)
    static let dappTransfer = BigInt(600_000)
}

public struct GasPriceConfiguration {
    static let `default`: BigInt = EtherNumberFormatter.full.number(from: "24", units: UnitConfiguration.gasPriceUnit)!
    static let min: BigInt = EtherNumberFormatter.full.number(from: "1", units: UnitConfiguration.gasPriceUnit)!
    static let max: BigInt = EtherNumberFormatter.full.number(from: "100", units: UnitConfiguration.gasPriceUnit)!
}

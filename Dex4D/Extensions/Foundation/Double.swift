//
//  Double.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/1.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

extension Double {
    func floorValue(bit: Int) -> Double {
        var n = bit
        var s = 1.0
        while n > 0 {
            n /= 10
            s *= 10
        }
        return floor(self * s) / s
    }
    func floor2Value() -> Double {
        return floor(self * 100) / 100
    }
    func floor6Value() -> Double {
        return floor(self * 1000000) / 1000000
    }
    func floor8Value() -> Double {
        return floor(self * 100000000) / 100000000
    }
    func stringValue() -> String {
        return String(self)
    }
    func stringFloorValue(bit: Int) -> String {
        return String(self.floorValue(bit: bit))
    }
    func stringFloor2Value() -> String {
        return String(format: "%.2f", self.floor2Value())
    }
    func stringFloor6Value() -> String {
        return String(format: "%.6f", self.floor6Value())
    }
    func stringFloor8Value() -> String {
        return String(format: "%.8f", self.floor8Value())
    }
    func intValue() -> Int {
        return Int(self)
    }
    func stringIntValue() -> String {
        return String(Int(self))
    }
    func floorValue() -> Double {
        return floor(self)
    }
    func floorIntValue() -> Int {
        return Int(floor(self))
    }
    func stringFloorValue() -> String {
        return String(self.floorValue())
    }
}

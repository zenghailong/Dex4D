////
////  Dex4DBalance.swift
////  Dex4D
////
////  Created by ColdChains on 2018/10/19.
////  Copyright © 2018 龙. All rights reserved.
////
//
//import Foundation
//import SwiftyJSON
//
//struct Dex4DCoinsLegeal {
//    var total: Double?
//    var eth: Double?
//    var seele: Double?
//    var omg: Double?
//    var zrx: Double?
//    var ethLegeal: Double?
//    var seeleLegeal: Double?
//    var omgLegeal: Double?
//    var zrxLegeal: Double?
//    var totalLegeal: Double? {
//        if ethLegeal != nil && seeleLegeal != nil && omgLegeal != nil && zrxLegeal != nil {
//            return ethLegeal! + seeleLegeal! + omgLegeal! + zrxLegeal!
//        }
//        return nil
//    }
//    init(json: JSON) {
//        total = json["total"].double
//        eth = json["eth"].double
//        seele = json["seele"].double
//        omg = json["omg"].double
//        zrx = json["zrx"].double
//        ethLegeal = json["ethLegeal"].double
//        seeleLegeal = json["seeleLegeal"].double
//        omgLegeal = json["omgLegeal"].double
//        zrxLegeal = json["zrxLegeal"].double
//    }
//}
//
//struct Dex4DCoinsPrice {
//    var total: Double?
//    var eth: Double?
//    var seele: Double?
//    var omg: Double?
//    var zrx: Double?
//    var totalPrice: Double?
//    var ethPrice: Double?
//    var seelePrice: Double?
//    var omgPrice: Double?
//    var zrxPrice: Double?
//    init(json: JSON) {
//        total = json["total"].double
//        eth = json["eth"].double
//        seele = json["seele"].double
//        omg = json["omg"].double
//        zrx = json["zrx"].double
//        totalPrice = json["totalPrice"].double
//        ethPrice = json["ethPrice"].double
//        seelePrice = json["seelePrice"].double
//        omgPrice = json["omgPrice"].double
//        zrxPrice = json["zrxPrice"].double
//    }
//}
//
//struct Dex4DBalance {
//    var coins: Dex4DCoinsLegeal?
//    var revenue: Dex4DCoinsLegeal?
//    var dividends: Dex4DCoinsLegeal?
//    var rebateFees: Dex4DCoinsLegeal?
//    var d4d: Dex4DCoinsPrice?
//    init(json: JSON) {
//        coins = Dex4DCoinsLegeal(json: json["coins"])
//        revenue = Dex4DCoinsLegeal(json: json["revenue"])
//        dividends = Dex4DCoinsLegeal(json: json["dividends"])
//        rebateFees = Dex4DCoinsLegeal(json: json["rebateFees"])
//        d4d = Dex4DCoinsPrice(json: json["d4d"])
//    }
//}
//
//extension Double {
//    func stringValue() -> String {
//        return String(format: "%.2f", self)
//    }
//}

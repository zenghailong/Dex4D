//
//  DexMarketcap.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import RealmSwift
import HandyJSON

final class DexMarketcap: Object, Decodable, HandyJSON {
    @objc dynamic var symbol = ""
    @objc dynamic var buy_price: Double = 0
    @objc dynamic var sell_price: Double = 0
    @objc dynamic var overall_volume: Double = 0
    @objc dynamic var dividends: Double = 0
    @objc dynamic var daily_volume: Double = 0
    @objc dynamic var daily_dividends: Double = 0
    @objc dynamic var price_flat: Double = 0
    @objc dynamic var market_cap_flat: Double = 0
    @objc dynamic var price_flat_cny: Double = 0
    @objc dynamic var market_cap_flat_cny: Double = 0
    @objc dynamic var total_token: Double = 0
    @objc dynamic var whitout_fee_price: Double = 0
    @objc dynamic var pre_24hours_price: Double = 0
    @objc dynamic var total_supply: Double = 0

    convenience init(
        symbol: String,
        buy_price: Double,
        sell_price: Double,
        overall_volume: Double,
        dividends: Double,
        daily_volume: Double,
        daily_dividends: Double,
        price_flat: Double,
        market_cap_flat: Double,
        price_flat_cny: Double,
        market_cap_flat_cny: Double,
        total_token: Double,
        whitout_fee_price: Double = 0,
        pre_24hours_price: Double = 0,
        total_supply: Double = 0
    ) {
        self.init()
        self.symbol = symbol
        self.buy_price = buy_price
        self.sell_price = sell_price
        self.overall_volume = overall_volume
        self.dividends = dividends
        self.daily_volume = daily_volume
        self.daily_dividends = daily_dividends
        self.price_flat = price_flat
        self.market_cap_flat = market_cap_flat
        self.price_flat_cny = price_flat_cny
        self.market_cap_flat_cny = market_cap_flat_cny
        self.total_token = total_token
        self.whitout_fee_price = whitout_fee_price
        self.pre_24hours_price = pre_24hours_price
        self.total_supply = total_supply
    }
    
    private enum DexMarketcapKeys: String, CodingKey {
        case symbol
        case buy_price
        case sell_price
        case overall_volume
        case dividends
        case daily_volume
        case daily_dividends
        case price_flat
        case market_cap_flat
        case price_flat_cny
        case market_cap_flat_cny
        case total_token
        case whitout_fee_price
        case pre_24hours_price
        case total_supply
    }
    
    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: DexMarketcapKeys.self)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let buy_price = try container.decode(Double.self, forKey: .buy_price)
        let sell_price = try container.decode(Double.self, forKey: .sell_price)
        let overall_volume = try container.decode(Double.self, forKey: .overall_volume)
        let dividends = try container.decode(Double.self, forKey: .dividends)
        let daily_volume = try container.decode(Double.self, forKey: .daily_volume)
        let daily_dividends = try container.decode(Double.self, forKey: .daily_dividends)
        let price_flat = try container.decode(Double.self, forKey: .price_flat)
        let market_cap_flat = try container.decode(Double.self, forKey: .market_cap_flat)
        let price_flat_cny = try container.decode(Double.self, forKey: .price_flat_cny)
        let market_cap_flat_cny = try container.decode(Double.self, forKey: .market_cap_flat_cny)
        let total_token = try container.decode(Double.self, forKey: .total_token)
        let whitout_fee_price = try container.decode(Double.self, forKey: .whitout_fee_price)
        let pre_24hours_price = try container.decode(Double.self, forKey: .pre_24hours_price)
        let total_supply = try container.decode(Double.self, forKey: .total_supply)
        
        self.init(
            symbol: symbol,
            buy_price: buy_price,
            sell_price: sell_price,
            overall_volume: overall_volume,
            dividends: dividends,
            daily_volume: daily_volume,
            daily_dividends: daily_dividends,
            price_flat: price_flat,
            market_cap_flat: market_cap_flat,
            price_flat_cny: price_flat_cny,
            market_cap_flat_cny: market_cap_flat_cny,
            total_token: total_token,
            whitout_fee_price: whitout_fee_price,
            pre_24hours_price: pre_24hours_price,
            total_supply: total_supply
        )
    }
    
    override static func primaryKey() -> String? {
        return "symbol"
    }
}


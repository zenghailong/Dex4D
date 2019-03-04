//
//  RPCServer.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/10.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct RPCServer {
    
    var id: String {
        return "ethereum"
    }
    
    var chainID: Int {
        return 4
    }
    
    var priceID: Address {
        return EthereumAddress(string: "0x000000000000000000000000000000000000003c")!
    }
    
    var isDisabledByDefault: Bool {
        return false
    }
    
    var name: String {
        return "Ethereum"
    }
    
    var symbol: String {
        return "ETH"
    }
    
    var decimals: Int {
        return 18
    }
    
    var coin: Coin {
        return Coin.ethereum
    }
    
    var logo: String {
        return "icon_eth"
    }
    
    var defaultERC20: [[String: String]] {
        return [
            ["symbol": "SEELE", "contract": "0xc1D5460DcF89c416210e5F2Fb546DA56401870Df", "logo": "icon_seele"],
            ["symbol": "OMG", "contract": "0x5D2493323de69f624f537933Cb85CD14379d7B4E", "logo": "icon_omg"],
            ["symbol": "ZRX", "contract": "0xBA34847782081F6B4d198286c75EEDCFA54d179E", "logo": "icon_zrx"]
        ]
    }
}

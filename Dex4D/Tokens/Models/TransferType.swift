//
//  TransferType.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct DAppRequester {
    let title: String?
    let url: URL?
}

struct Transfer {
    let server: RPCServer
    let type: TransferType
}


enum TransferType {
    case ether(TokenObject, destination: EthereumAddress?)
    case token(TokenObject)
    case dapp(TokenObject, DAppRequester)
}

extension TransferType {
    
    func symbol(server: RPCServer) -> String {
        switch self {
        case .ether, .dapp:
            return server.symbol
        case .token(let token):
            return token.symbol
        }
    }
    
    //used for pricing
    var contract: String {
        switch self {
        case .ether(let token, _):
            return token.contract
        case .dapp(let token, _):
            return token.contract
        case .token(let token):
            return token.contract
        }
    }
    
    var token: TokenObject {
        switch self {
        case .ether(let token, _):
            return token
        case .dapp(let token, _):
            return token
        case .token(let token):
            return token
        }
    }
    
    var address: EthereumAddress {
        switch self {
        case .ether(let token, _):
            return token.address
        case .dapp(let token, _):
            return token.address
        case .token(let token):
            return token.address
        }
    }
}

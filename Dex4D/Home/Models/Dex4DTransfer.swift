//
//  Dex4DTransfer.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/8.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

struct Dex4DTransfer {
    let server: RPCServer
    let type: Dex4DTransferType
}


enum Dex4DTransferType {
    case ether
    case token
}

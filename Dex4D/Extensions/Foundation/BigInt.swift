//
//  BigInt.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/23.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import BigInt

extension BigInt {
    var hexEncoded: String {
        return "0x" + String(self, radix: 16)
    }
}

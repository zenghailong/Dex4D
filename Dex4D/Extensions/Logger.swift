//
//  Logger.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

class DebugLogger: NSObject {
    
    static func log(item: Any) {
        
        #if DEBUG
        print(item)
        #else
        
        #endif
    }
}

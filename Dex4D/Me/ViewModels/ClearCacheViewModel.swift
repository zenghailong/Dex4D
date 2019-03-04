//
//  File.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/8.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

class ClearCacheViewModel {
    
    var title = "Browser".localized
    
    var dataSource: [CellModel] = {
        return [
            CellModel(title: "Clear cache".localized, action: "clearCache")
        ]
    }()
    
}

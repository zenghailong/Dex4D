//
//  Common.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

struct CellModel {
    
    var title: String
    var image: UIImage?
    var detail: String?
    var action: String?
    var push: String?
    var value: Any?
    
    init(
        title: String = "",
        image: UIImage? = nil,
        detail: String? = nil,
        action: String? = nil,
        push: String? = nil,
        value: Any? = nil
    ) {
        self.title = title
        self.image = image
        self.detail = detail
        self.action = action
        self.push = push
        self.value = value
    }
    
}

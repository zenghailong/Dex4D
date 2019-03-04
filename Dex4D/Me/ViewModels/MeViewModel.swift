//
//  MeViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class MeViewModel {
    
    var dataSource: [[CellModel]] {
        return [
            [
            CellModel(title: "Setting".localized, image: R.image.icon_setting(), action: "pushToSetting"),
            CellModel(title: "Authority".localized, image: R.image.icon_authority(), action: "pushToAuthority"),
            CellModel(title: "About".localized, image: R.image.icon_about(), push: "AboutViewController")
            ]
        ]
    }
    
}

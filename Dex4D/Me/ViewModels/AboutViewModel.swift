//
//  VersionViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class AboutViewModel {
    
    var title = "About".localized
    
    private var version: String? {
        let infoDictionary = Bundle.main.infoDictionary!
        let version = infoDictionary["CFBundleShortVersionString"] as? String
        return version
    }
    
    var dataSource: [CellModel] {
        return [
            CellModel(title: "Help center".localized, action: "pushToHelp"),
            CellModel(title: "Current Version".localized, detail: version, action: "checkUpdate")
        ]
    }
    
}

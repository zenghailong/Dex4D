//
//  SettingViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class SettingViewModel {
    
    var title = "Setting".localized
    
    var dataSource: [CellModel] {
        get {
            return [
                CellModel(title: "Language".localized, action: "pushToLanguage"),
                CellModel(title: "Currency".localized, push: "ChangeCurrencyViewController"),
                CellModel(title: "Security".localized, action: "pushToSecurity")
//                ,CellModel(title: "Clear browser cache".localized, detail: ClearCacheManage.sizeOfBrowserCache(), action: "clearBrowserCache")
//                ,CellModel(title: "Clear cache".localized, detail: ClearCacheManage.sizeOfAllCache(), action: "clearCache")
            ]
        }
    }
    
}

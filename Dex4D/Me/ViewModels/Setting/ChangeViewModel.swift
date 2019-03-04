//
//  ChangeViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class ChangeViewModel {
    
    var title: String {
        switch type {
        case .language:
            return "Language".localized
        case .currency:
            return "Currency".localized
        default :
            return ""
        }
    }
    
    var dataSource: [CellModel] {
        switch type {
        case .language:
            return [
                CellModel(title: "English", action: "changeEnglish", value: Language.english),
                CellModel(title: "中文", action: "changeChinese", value: Language.chinese)
            ]
        case .currency:
            return [
                CellModel(title: "USD", action: "changeUSD", value: Currency.USD),
                CellModel(title: "CNY", action: "changeCNY", value: Currency.CNY)
            ]
        default:
            return []
        }
    }
    
    let type: CommonTableViewCellStyle
    
    init(type: CommonTableViewCellStyle) {
        self.type = type
    }
    
}

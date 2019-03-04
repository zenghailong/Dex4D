//
//  AuthorityViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class AuthorityViewModel {
    
    var title = "Authority".localized
    
    var dataSource: [CellModel] {
        return [
            CellModel(title: "Referral".localized, action: "pushToReferral"),
            CellModel(title: "Swap".localized, action: "pushToSwap")
        ]
    }
    
    let account: WalletInfo
    
    init(account: WalletInfo) {
        self.account = account
    }
    
}

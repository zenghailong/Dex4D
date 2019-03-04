//
//  TradeControllerViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/5.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result

struct TradeControllerViewModel  {
    
    let account: WalletInfo
    
    var titleText: String {
        return "Trade".localized
    }
    
    init(account: WalletInfo) {
        self.account = account
    }
    
    func isHaveSwapAuthority(completion: @escaping (Bool) -> Void) {
        Dex4DProvider.shared.hasDex4DSwapAuthority(address: account.address.description) { result in
            switch result {
            case .success(let isAuthority):
                if isAuthority == 1 {
                    completion(true)
                } else {
                    Dex4DProvider.shared.getDex4DBalance(address: self.account.address.description) { result in
                        switch result {
                        case .success(let data):
                            guard let d4d = data["d4d"] as? [String: Any] else { return }
                            guard let total = d4d["total"] as? Double else { return }
                            if total > AuthorityOperation(operation: .swap).dex4DCount {
                                completion(true)
                            } else {
                                completion(false)
                            }
                            break
                        case .failure(_):
                            break
                        }
                    }
                }
            case .failure(_): break
            }
        }
    }
}

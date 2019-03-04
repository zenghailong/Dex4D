//
//  InvitationCodeViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/31.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class InvitationCodeViewModel {
    var titleText: String {
        return "Please enter your invitation code".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        return "Dex4D app is an referral application and you won't be able to experience it if you don't have an referral link.".localized
    }
    
    var descriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    var descriptionTextColor: UIColor {
        return UIColor(hex: "B8C5CD")
    }
    
    var continueBtnTextFont: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    var continueBtnText: String {
        return "Confirm".localized
    }
}

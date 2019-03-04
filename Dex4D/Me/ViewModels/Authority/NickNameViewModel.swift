//
//  NickNameViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/31.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class NickNameViewModel {
    
    var titleText: String {
        return "Referral address".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        return "Register your referral address(Begin with letter)".localized
    }
    
    var descriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    
    var descriptionTextColor: UIColor {
        return UIColor.white
    }
    
    var continueBtnTextFont: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    var continueBtnText: String {
        return "Confirm".localized
    }
    
}

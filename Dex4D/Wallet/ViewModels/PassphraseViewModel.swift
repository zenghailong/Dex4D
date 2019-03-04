//
//  PassphraseViewModel.swift
//  Dex4D
//
//  Created by zeng hai long on 14/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

enum PassphraseOption {
    case first
    case read
}

struct PassphraseViewModel {
    
    var titleText: String {
        return "Protect your asset before it's too late!".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        switch option {
        case .first:
            return "Dex4D is a app on your phone. If you lose your phone, you can access your account with a wallet recovery phrase very easily.".localized
        default:
            return ""
        }
    }
    
    var warningText: String {
        return "Write down your recovery phrase and keep it in a safe place. Dex4D team cannot reset it or recover your money for you.".localized
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
    
    var remindBtnTextFont: UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    var remindBtnText: String {
        return "Remind me later".localized
    }
    
    var continueBtnText: String {
        switch option {
        case .first:
            return "Continue".localized
        default:
            return "Confirm".localized
        }
    }
    
    let option: PassphraseOption
    
    init(option: PassphraseOption) {
        self.option = option
    }
    
}

//
//  ImportMnemonicViewModel.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

struct ImportMnemonicViewModel {
    var titleText: String {
        return "Restore wallet".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        return "Please input your memoric phrase to restore your wallet or import your wallet(Typically 12, separately with blank)".localized
    }
    
    var descriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    var descriptionTextColor: UIColor {
        return UIColor(hex: "B8C5CD")
    }
    
    var confirmBtnTextFont: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    var inValidConfirmBtnColor: UIColor {
        return UIColor(hex: "315968")
    }
    
    var inValidConfirmTextColor: UIColor {
        return UIColor(hex: "B7C5CA")
    }
    
    var inValidConfirmBtnText: String {
        return "Confirm".localized
    }
}

//
//  ImportKeystoreViewModel.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

struct ImportKeystoreViewModel {
    
    var titleText: String {
        return "Restore wallet".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        return "Please input your keystore file to restore your wallet or import your wallet".localized
    }
    
    var descriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 12)
    }
    
    var descriptionTextColor: UIColor {
        return UIColor(hex: "B8C5CD")
    }
    
    var finishedBtnTextFont: UIFont {
        return UIFont.systemFont(ofSize: 16)
    }
    
    var inValidFinishedBtnColor: UIColor {
        return UIColor(hex: "315968")
    }
    
    var inValidFinishedTextColor: UIColor {
        return UIColor(hex: "B7C5CA")
    }
    
    var finishedBtnText: String {
        return "Finished".localized
    }
}

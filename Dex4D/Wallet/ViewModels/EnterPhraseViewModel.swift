//
//  EnterPhraseViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

struct EnterPhraseViewModel {
    
    var titleText: String {
        return "Enter phrase".localized
    }
    
    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 22)
    }
    
    var description: String {
        return "Check that you wrote it down correctly so you can protect your money.".localized
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
    
    var inValidFinishedBtnText: String {
        return "Finished".localized
    }
}

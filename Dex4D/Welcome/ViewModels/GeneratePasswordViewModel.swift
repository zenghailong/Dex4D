//
//  GeneratePasswordViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

enum GeneratePasswordType {
    case input
    case confirm
    case memoric
    case keystore
    case verify
}

struct GeneratePasswordViewModel {
    
    private let type: GeneratePasswordType
    
    init(type: GeneratePasswordType) {
        self.type = type
    }
    
    var description: String {
        switch type {
        case .input:
            return "Create your PIN".localized
        case .confirm:
            return "Confirm your PIN".localized
        default :
            return "Input your PIN".localized
        }
        
    }
    
    var errorText: String {
        switch type {
        case .confirm:
            return "PIN not match".localized
        default :
            return "Incorrect PIN".localized
        }
    }
    
    var circleSize: CGFloat {
        return 38
    }
    
    var pinViewSize: CGFloat {
        return 283
    }
    
    var circleCount: Int {
        return 6
    }
}

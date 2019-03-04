//
//  SendInputErrors.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

enum SendInputErrors: LocalizedError {
    case emptyClipBoard
    case wrongInput
    
    var errorDescription: String? {
        switch self {
        case .emptyClipBoard:
            return NSLocalizedString("send.error.emptyClipBoard", value: "Empty ClipBoard", comment: "")
        case .wrongInput:
            return NSLocalizedString("send.error.wrongInput", value: "Wrong Input", comment: "")
        }
    }
}

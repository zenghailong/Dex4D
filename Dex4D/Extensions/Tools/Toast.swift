//
//  Toast.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/15.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

class Toast {
    class func showMessage(message: String? = "") {
        if message == "" { return }
        if let window = UIApplication.shared.delegate?.window {
            window?.viewWithTag(999)?.removeFromSuperview()
            window?.makeToast(message, duration: 2, position: CSToastPositionCenter)
        }
    }
}

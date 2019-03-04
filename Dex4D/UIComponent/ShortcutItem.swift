//
//  ShortcutItem.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/30.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

enum ShortcutItem {
    case scan
    case send
    case receive
    case qrcode
    var type: String {
        switch self {
        case .scan:
            return "com.dex4d.scan"
        case .send:
            return "com.dex4d.send"
        case .receive:
            return "com.dex4d.receive"
        case .qrcode:
            return "com.dex4d.qrcode"
        }
    }
    var title: String {
        switch self {
        case .scan:
            return "Scan".localized
        case .send:
            return "Send".localized
        case .receive:
            return "Receive".localized
        case .qrcode:
            return "My referral code".localized
        }
    }
    var imageName: String {
        switch self {
        case .scan:
            return "tabbar_wallet"
        case .send:
            return "tabbar_wallet"
        case .receive:
            return "tabbar_wallet"
        case .qrcode:
            return "tabbar_wallet"
        }
    }
    var icon: UIApplicationShortcutIcon {
        return UIApplicationShortcutIcon(templateImageName: self.imageName)
    }
}

//
//  Bundle.swift
//  Dex4D
//
//  Created by lax on 2018/11/26.
//  Copyright © 2018 龙. All rights reserved.
//

import Foundation

extension Bundle {
    
    var appDisplayName: String {
        if let name = infoDictionary?["CFBundleDisplayName"] as? String {
            return name
        }
        return ""
    }
    var appVersion: String {
        if let version = infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return ""
    }
    var buildVersion: String {
        if let version = infoDictionary?["CFBundleVersion"] as? String {
            return version
        }
        return ""
    }
    
}

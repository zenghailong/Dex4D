//
//  UIFont.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

extension UIFont {
    class func defaultFont(size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica", size: size) ?? UIFont.systemFont(ofSize: size)
    }
}

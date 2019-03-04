//
//  TabBarViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/11.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.isTranslucent = false
        tabBar.barTintColor = Colors.barTint
        tabBar.tintColor = Colors.globalColor
    }

}

extension TabBarViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
}

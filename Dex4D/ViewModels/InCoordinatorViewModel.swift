//
//  InCoordinatorViewModel.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

struct InCoordinatorViewModel {
    
    var imageInsets: UIEdgeInsets {
        return UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
    }
    
    var homeTabBarItem: UITabBarItem {
        let item = UITabBarItem(
            title: "Dex4D".localized,
            image: R.image.tabbar_dex4d(),
            selectedImage: R.image.tabbar_dex4d_selected()
        )
        moveTabbarItemPosition(item)
        return item
    }
    
    var walletTabBarItem: UITabBarItem {
        let item = UITabBarItem(
            title: "Wallet".localized,
            image: R.image.tabbar_wallet(),
            selectedImage: R.image.tabbar_wallet_selected()
        )
        moveTabbarItemPosition(item)
        return item
    }

    var browserTabBarItem: UITabBarItem {
        let item = UITabBarItem(
            title: "Browser".localized,
            image: R.image.tabbar_browser(),
            selectedImage: R.image.tabbar_browser_selected()
        )
        moveTabbarItemPosition(item)
        return item
    }

    var meTabBarItem: UITabBarItem {
        let item = UITabBarItem(
            title: "Me".localized,
            image: R.image.tabbar_me(),
            selectedImage: R.image.tabbar_me_selected()
        )
        moveTabbarItemPosition(item)
        return item
    }
    
    private func moveTabbarItemPosition(_ item: UITabBarItem) {
        item.titlePositionAdjustment = UIOffsetMake(0, -2)
    }
    
}

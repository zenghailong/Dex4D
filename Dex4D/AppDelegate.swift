//
//  AppDelegate.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/25.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    let launchScreenView = LaunchScreenView()
    
    var coordinator: AppCoordinator!
    
    @objc private func getNetworking() {
        if WebSocketProvider.shared.isConnected == false {
            WebSocketProvider.shared.socket.connect()
        }
    }
    
    private func addLaunchScreenView() {
        launchScreenView.removeFromSuperview()
        window?.addSubview(launchScreenView)
        launchScreenView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

extension AppDelegate {
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        if #available(iOS 11.0, *) {
            UITableView.appearance().estimatedRowHeight = 0
        }
        
        LocalizationTool.shared.checkLanguageAndCurrency()
        NetworkingManager.startListenNetwork()
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        coordinator = AppCoordinator(window: window!)
        coordinator.start()
        
        if TouchIdManager.hasTouchId && UserDefaults.getBoolValue(for: Dex4DKeys.touchId) {
            UserDefaults.setBoolValue(value: false, key: Dex4DKeys.touchIdUnlock)
            let vc = FingerPrintUnlockViewController()
            window?.rootViewController?.present(vc, animated: false, completion: nil)
        }
        
        AppUpdateManager().check()
        createShortcutItems()
        NotificationCenter.default.addObserver(self, selector: #selector(self.getNetworking), name: NotificationNames.getNetworking, object: nil)
        
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        if !TouchIdManager.hasTouchId || (TouchIdManager.hasTouchId && UserDefaults.getBoolValue(for: Dex4DKeys.touchIdUnlock)) {
            addLaunchScreenView()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        launchScreenView.removeFromSuperview()
        if WebSocketProvider.shared.isConnected == false {
            WebSocketProvider.shared.socket.connect()
        }
    }
}

extension AppDelegate {
    func createShortcutItems() {
        if #available(iOS 9.1, *) {
            var itemArray: [UIApplicationShortcutItem] = []
            for item in [ShortcutItem.scan, ShortcutItem.send, ShortcutItem.receive, ShortcutItem.qrcode] {
                itemArray.append(UIApplicationShortcutItem(type: item.type, localizedTitle: item.title, localizedSubtitle: nil, icon: item.icon, userInfo: nil))
            }
            UIApplication.shared.shortcutItems = itemArray
        }
    }
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        guard let main = appDelegate.coordinator.coordinators.first as? MainCoordinator else { return }
        switch shortcutItem.type {
        case ShortcutItem.scan.type:
            if main.tabBarController.selectedIndex != 0, let nvc = main.tabBarController.viewControllers?[main.tabBarController.selectedIndex] as? UINavigationController {
                nvc.popToRootViewController(animated: false)
                main.tabBarController.selectedIndex = 0
            }
            main.homeCoordinator.gotoScanCoordinator()
        case ShortcutItem.send.type:
            if main.tabBarController.selectedIndex != 1, let nvc = main.tabBarController.viewControllers?[main.tabBarController.selectedIndex] as? UINavigationController {
                nvc.popToRootViewController(animated: false)
                main.tabBarController.selectedIndex = 1
            }
            main.tokensCoordinator.pushToSend()
        case ShortcutItem.receive.type:
            if main.tabBarController.selectedIndex != 1, let nvc = main.tabBarController.viewControllers?[main.tabBarController.selectedIndex] as? UINavigationController {
                nvc.popToRootViewController(animated: false)
                main.tabBarController.selectedIndex = 1
            }
            main.tokensCoordinator.pushToReceive()
        case ShortcutItem.qrcode.type:
            if main.tabBarController.selectedIndex != 3, let nvc = main.tabBarController.viewControllers?[main.tabBarController.selectedIndex] as? UINavigationController {
                nvc.popToRootViewController(animated: false)
                main.tabBarController.selectedIndex = 3
            }
            main.meCoordinator.pushToQRCode()
        default:
            break
        }
    }
}



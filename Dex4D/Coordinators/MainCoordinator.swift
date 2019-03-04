//
//  MainCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import RealmSwift

class MainCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    var keystore: Keystore
    let keyWindow: UIWindow
    let walletInfo: WalletInfo
    let walletSession: WalletSession
    let config: Config
    
    let tabBarController: TabBarViewController
    
    var homeCoordinator: HomeCoordinator
    
    var tokensCoordinator: TokensCoordinator
    
    var browserCoordinator: BrowserCoordinator
    
    var meCoordinator: MeCoordinator
    
    init(keystore: Keystore,
         window: UIWindow,
         walletInfo: WalletInfo,
         config: Config = .current
    ) {
        self.keystore = keystore
        self.keyWindow = window
        self.walletInfo = walletInfo
        self.config = config
        
        tabBarController = TabBarViewController()
        let viewModel = InCoordinatorViewModel()
        
        let migration = MigrationInitializer(account: walletInfo)
        migration.perform()
        
        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        
        let dexMigration = DexMigrationInitializer()
        dexMigration.perform()
        
        let realm = try! Realm(configuration: migration.config)
        let sharedRealm = try! Realm(configuration: sharedMigration.config)
        let dexRealm = try! Realm(configuration: dexMigration.config)
        
        walletSession = WalletSession(
            walletInfo: walletInfo,
            realm: realm,
            sharedRealm: sharedRealm,
            config: config
        )
        
        homeCoordinator = HomeCoordinator(
            keystore: keystore,
            session: walletSession,
            realm: dexRealm,
            tabBarItem: viewModel.homeTabBarItem
        )
        tokensCoordinator = TokensCoordinator(
            keystore: keystore,
            tokensStorage: walletSession.tokensStorage,
            session: walletSession,
            tabBarItem: viewModel.walletTabBarItem
        )
        browserCoordinator = BrowserCoordinator(
            session: walletSession,
            keystore: keystore,
            tabBarItem: viewModel.browserTabBarItem
        )
        meCoordinator = MeCoordinator(
            session: walletSession,
            keystore: keystore,
            tokensStorage: walletSession.tokensStorage,
            tabBarItem: viewModel.meTabBarItem
        )
        
        
        homeCoordinator.start()
        addCoordinator(homeCoordinator)
        
        tokensCoordinator.start()
        addCoordinator(tokensCoordinator)
        
        browserCoordinator.start()
        addCoordinator(browserCoordinator)
        
        meCoordinator.start()
        addCoordinator(meCoordinator)
        
        tabBarController.viewControllers = [
            homeCoordinator.navigationController,
            tokensCoordinator.navigationController,
            browserCoordinator.navigationController,
            meCoordinator.navigationController
        ]
    }
    
    func start() {
        showTabBar()
        NotificationCenter.default.addObserver(self, selector: #selector(observeD4dTransaction), name: NotificationNames.websocketConnected, object: nil)
    }
    
    func startAt(index: Int) {
        showTabBar()
        if tabBarController.viewControllers?.count ?? 0 > index {
            tabBarController.selectedIndex = index
        }
    }
    
    private func showTabBar() {
        keyWindow.rootViewController = tabBarController
        keystore.recentlyUsedWallet = walletInfo
        UserDefaults.standard.set(true, forKey: Dex4DKeys.initialWalletDoneKey)
    }
    
    @objc func observeD4dTransaction() {
        WebSocketService.getPersonTradingList(account: walletInfo.address.description)
        WebSocketService.getDexTokenDetail()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

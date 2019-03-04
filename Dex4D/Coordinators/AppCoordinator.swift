//
//  AppCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import RealmSwift

enum EnterType {
    case created
    case imported
    case none
}

class AppCoordinator: NSObject, Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let socketProvider: WebSocketProvider
    let keystore: Keystore
    
    let keyWindow: UIWindow
    let navigationController: NavigationController = NavigationController()
    var walletInfo: WalletInfo?
    
    init(window: UIWindow) {
        let sharedMigration = SharedMigrationInitializer()
        sharedMigration.perform()
        let realm = try! Realm(configuration: sharedMigration.config)
        let walletStorage = WalletStorage(realm: realm)
        self.keystore = EtherKeystore(storage: walletStorage)
        self.socketProvider = WebSocketProvider.shared
        self.keyWindow = window
    }
    
    func start() {
        if UserDefaults.hasValueForKey(key: Dex4DKeys.invitationCode) {
//            enterApp(inputPin: true)
            enterApp(inputPin: false)
        } else {
            enterInvitationCodeCoordinator(enterType: .created)
        }
    }
    
    func enterApp(inputPin: Bool) {
        socketProvider.webSocketOpen()
        if keystore.hasWallets {
            if let isInitialWalletDone = UserDefaults.standard.object(forKey: Dex4DKeys.initialWalletDoneKey) as? Bool, isInitialWalletDone == true {
                let wallet = keystore.recentlyUsedWallet ?? keystore.wallets.first!
                walletInfo = wallet
                if inputPin {
                    enterPinCoordinator(enterType: .none, type: .verify)
                } else {
                    enterMainCoordinator(for: wallet)
                }
                return
            }
        }
        enterWelcomeCoordinator()
    }
    
    func enterWelcomeCoordinator() {
        let coordinator = WelcomeCoordinator(
            window: keyWindow,
            navigationController: navigationController
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func enterPinCoordinator(enterType: EnterType, type: GeneratePasswordType) {
        let coordinator = CreatePINCoordinator(
            navigationController: navigationController,
            enterType: enterType,
            type: type
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func enterInvitationCodeCoordinator(enterType: EnterType) {
        let coordinator = InvitationCodeCoordinator(
            navigationController: navigationController,
            enterType: enterType
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func enterWalletCoordinator(enterType: EnterType) {
        let coordinator = InitialWalletCoordinator(
            keystore: keystore,
            enterType: enterType,
            navigationController: navigationController
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
    
    func enterMainCoordinator(for walletInfo: WalletInfo) {
        let coordinator = MainCoordinator(
            keystore: keystore,
            window: keyWindow,
            walletInfo: walletInfo
        )
        coordinator.start()
        removeAllCoordinators()
        addCoordinator(coordinator)
    }
    
}

extension AppCoordinator: WelcomeCoordinatorDelegate {
    func didSelectItem(coordinator: Coordinator, enterType: EnterType, type: GeneratePasswordType) {
        enterPinCoordinator(enterType: enterType, type: type)
    }
}

extension AppCoordinator: CreatePINCoordinatorDelegate {
    func didCancel(in coordinator: CreatePINCoordinator) {
        removeCoordinator(coordinator)
    }
    func createPinDone(for enterType: EnterType, coordinator: CreatePINCoordinator) {
        removeCoordinator(coordinator)
        enterWalletCoordinator(enterType: enterType)
    }
    func didVerifyPassword(coordinator: Coordinator, type: GeneratePasswordType) {
        removeCoordinator(coordinator)
        if let walletInfo = walletInfo {
            enterMainCoordinator(for: walletInfo)
        }
    }
}

extension AppCoordinator: InvitationCodeCoordinatorDelegate {
    func didEnterInvitationCode(coordinator: Coordinator, enterType: EnterType) {
        removeCoordinator(coordinator)
        enterApp(inputPin: false)
    }
}

extension AppCoordinator: InitialWalletCoordinatorDelegate {
    func didCancel(in coordinator: InitialWalletCoordinator) {
        removeCoordinator(coordinator)
    }
    func didAddAccount(_ account: WalletInfo, in coordinator: InitialWalletCoordinator) {
        removeCoordinator(coordinator)
        enterMainCoordinator(for: account)
    }
}


//
//  WelcomeCoordinator.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/2.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol WelcomeCoordinatorDelegate: class {
    func didSelectItem(coordinator: Coordinator, enterType: EnterType, type: GeneratePasswordType)
}

final class WelcomeCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    weak var delegate: WelcomeCoordinatorDelegate?
    
    let keyWindow: UIWindow
    let navigationController: NavigationController
    
    lazy var welcomeController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()
    
    init(
        window: UIWindow,
        navigationController: NavigationController
        ) {
        self.keyWindow = window
        self.navigationController = navigationController
    }
    
    func start() {
        navigationController.viewControllers = [welcomeController]
        navigationController.setNavigationBarHidden(true, animated: true)
        keyWindow.rootViewController = navigationController
        UserDefaults.standard.set(false, forKey: Dex4DKeys.initialWalletDoneKey)
    }
    
}

extension WelcomeCoordinator: WelcomeViewControllerDelegate {
    func didPressCreateWallet() {
        delegate?.didSelectItem(coordinator: self, enterType: .created, type: .input)
    }
    func didPressImportWallet() {
        delegate?.didSelectItem(coordinator: self, enterType: .imported, type: .input)
    }
}


//
//  CreatePINCoordinator.swift
//  Dex4D
//
//  Created by zeng hai long on 20/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol CreatePINCoordinatorDelegate: class {
    func createPinDone(for enterType: EnterType, coordinator: CreatePINCoordinator)
    func didCancel(in coordinator: CreatePINCoordinator)
    func didVerifyPassword(coordinator: Coordinator, type: GeneratePasswordType)
}

final class CreatePINCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    weak var delegate: CreatePINCoordinatorDelegate?
    let navigationController: NavigationController
    let enterType: EnterType
    let type: GeneratePasswordType
    
    init(
        navigationController: NavigationController,
        enterType: EnterType,
        type: GeneratePasswordType
    ) {
        self.navigationController = navigationController
        self.enterType = enterType
        self.type = type
    }
    
    func start() {
        let vc = GenerateEnterPasswordController(type: type, coordinator: self)
        vc.delegate = self
        if type == .verify {
            navigationController.viewControllers = [vc]
            navigationController.setNavigationBarHidden(true, animated: true)
            UIApplication.shared.delegate?.window??.rootViewController = navigationController
        } else {
            navigationController.pushViewController(vc, animated: true)
        }
    }
    
}

extension CreatePINCoordinator: GenerateEnterPasswordControllerDelegate {
    func didCancelCreatePin(in viewController: GenerateEnterPasswordController) {
        delegate?.didCancel(in: self)
    }
    func didFinishedCreatePin(in viewController: GenerateEnterPasswordController) {
        delegate?.createPinDone(for: enterType, coordinator: self)
    }
    func didVerifyPassword(type: GeneratePasswordType) {
        delegate?.didVerifyPassword(coordinator: self, type: type)
    }
}

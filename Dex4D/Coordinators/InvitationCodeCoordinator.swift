//
//  EnterInvitationCodeCoordinator.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/2.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol InvitationCodeCoordinatorDelegate: class {
    func didEnterInvitationCode(coordinator: Coordinator, enterType: EnterType)
}

final class InvitationCodeCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    weak var delegate: InvitationCodeCoordinatorDelegate?
    
    let navigationController: NavigationController
    let enterType: EnterType
    
    init(
        navigationController: NavigationController,
        enterType: EnterType
    ) {
        self.navigationController = navigationController
        self.enterType = enterType
    }
    
    func start() {
        let vc = InvitationCodeViewController()
        vc.delegate = self
        navigationController.viewControllers = [vc]
        navigationController.setNavigationBarHidden(true, animated: true)
        UIApplication.shared.delegate?.window??.rootViewController = navigationController
    }
    
}

extension InvitationCodeCoordinator: InvitationCodeViewControllerDelegate {
    func didEnterInvitationCode() {
        delegate?.didEnterInvitationCode(coordinator: self, enterType: enterType)
    }
}

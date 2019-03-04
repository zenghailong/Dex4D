//
//  DexConfirmSendCoordinator.swift
//  Dex4D
//
//  Created by zeng hai long on 21/11/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import Result

protocol DexConfirmSendCoordinatorDelegate: class {
    func didCancelToSend(in coordinator: DexConfirmSendCoordinator)
}

final class DexConfirmSendCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    weak var delegate: DexConfirmSendCoordinatorDelegate?
    
    private let keystore: Keystore
    let session: WalletSession

    var didCompleted: ((Result<ConfirmResult, AnyError>, _ txHash: String?, _ isAuthorized: Bool) -> Void)?
    let configurator: DexTransactionConfigurator
    let account: Account
    let navigationController: UINavigationController
    let isAuthCompleted: Bool
    let isAuthorized: Bool
    let method: PayMethod
    
    private lazy var controller: PayConfirmViewController = {
        return PayConfirmViewController(
            session: session,
            keystore: keystore,
            configurator: configurator,
            account: account,
            isAuthCompleted: isAuthCompleted,
            isAuthorized: isAuthorized,
            method: method
        )
    }()
    
    init(
        session: WalletSession,
        keystore: Keystore,
        configurator: DexTransactionConfigurator,
        isAuthCompleted: Bool = false,
        isAuthorized: Bool = false,
        method: PayMethod,
        navigationController: UINavigationController
    ) {
        self.session = session
        self.keystore = keystore
        self.configurator = configurator
        self.account = configurator.account
        self.navigationController = navigationController
        self.isAuthCompleted = isAuthCompleted
        self.isAuthorized = isAuthorized
        self.method = method
        self.start()
    }
    
    func start() {
        controller.delegate = self
        controller.didCompleted = {[weak self] (result, txHash, isAuthorized) in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                self.didCompleted?(.success(data), txHash, isAuthorized)
            case .failure(let error):
                self.didCompleted?(.failure(error), nil, isAuthorized)
            }
        }
        navigationController.present(controller, animated: true, completion: nil)
    }
    
}

extension DexConfirmSendCoordinator: PayConfirmViewControllerDelegate {
    func didCancelToSend() {
        delegate?.didCancelToSend(in: self)
    }
}

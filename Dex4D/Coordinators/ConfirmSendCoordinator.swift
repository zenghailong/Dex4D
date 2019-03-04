//
//  ConfirmSendCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/20.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import Result

enum ConfirmType {
    case sign
    case signThenSend
}

enum ConfirmResult {
    case signedTransaction(SentTransaction)
    case sentTransaction(SentTransaction)
}

protocol ConfirmSendCoordinatorDelegate: class {
    func didCancelToSend(in coordinator: ConfirmSendCoordinator)
}

final class ConfirmSendCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    weak var delegate: ConfirmSendCoordinatorDelegate?
    
    private let keystore: Keystore
    
    let session: WalletSession
    
    var didCompleted: ((Result<ConfirmResult, AnyError>, _ txHash: String?) -> Void)?
    
    let confirmType: ConfirmType
    let server: RPCServer
    let configurator: TransactionConfigurator
    let account: Account
    let token: TokenObject
    let navigationController: NavigationController
    
    private lazy var controller: ConfirmViewController = {
        return ConfirmViewController(
            session: session,
            keystore: keystore,
            confirmType: confirmType,
            server: server,
            configurator: configurator,
            account: account,
            token: token
        )
    }()
    
    init(
        session: WalletSession,
        keystore: Keystore,
        confirmType: ConfirmType,
        server: RPCServer,
        configurator: TransactionConfigurator,
        account: Account,
        token: TokenObject,
        navigationController: NavigationController
    ) {
        self.session = session
        self.keystore = keystore
        self.confirmType = confirmType
        self.server = server
        self.account = account
        self.token = token
        self.configurator = configurator
        self.navigationController = navigationController
        start()
    }
    
    func start() {
        controller.delegate = self
        controller.didCompleted = { [weak self] (result, txHash) in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                self.didCompleted?(.success(data), txHash)
            case .failure(let error):
                self.didCompleted?(.failure(error), nil)
            }
        }
        navigationController.present(controller, animated: true, completion: nil)
    }
}

extension ConfirmSendCoordinator: ConfirmViewControllerDelegate {
    func didCancelToSend() {
        delegate?.didCancelToSend(in: self)
    }
}

//
//  ScanCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/21.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation

protocol ScanCoordinatorDelegate: class {
    func scanResult(for address: String, coordinator: ScanCoordinator)
    func scanCompleted(in coordinator: ScanCoordinator)
    func scanPayment(for payData: ScanPaymentInfo, qrInfo: String, viewController: UIViewController)
}

final class ScanCoordinator: Coordinator {
    
    weak var delegate: ScanCoordinatorDelegate?
    
    var coordinators: [Coordinator] = []
    
    let navigationController: NavigationController
    let targetController: UIViewController
    let session: WalletSession
    
    lazy var controller: ScanViewController = {
        let controller = ScanViewController()
        controller.delegate = self
        return controller
    }()
    
    init(
        targetController: UIViewController,
        session: WalletSession,
        navigationController: NavigationController = NavigationController()
    ) {
        self.targetController = targetController
        self.session = session
        self.navigationController = navigationController
    }
    
    func start() {
        targetController.pushToScan(navigationController: navigationController, push: controller)
    }
}

extension ScanCoordinator: ScanViewControllerDelegate {
    func didScanQRCode(result: String) {
        if result.isEthereumAddress() {
            delegate?.scanResult(for: result, coordinator: self)
        } else if result.hasPrefix("http") {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator {
                main.browserCoordinator.rootViewController.urlString = result
                main.tabBarController.selectedIndex = 2
                navigationController.popViewController(animated: true)
                delegate?.scanCompleted(in: self)
            }
        } else if result.hasPrefix("/qrlogin") {
            let address = session.account.currentAccount.address.description
            ScanProvider.shared.qrLogin(
                appname: result.qrStringAppName(),
                nonce: result.qrStringNonce(),
                address: address
            ) {[weak self] (res) in
                guard let `self` = self else { return }
                switch res {
                case .success(_):
                    self.navigationController.popViewController(animated: false)
                    let vc = LoginConfirmViewController(qrString: result, address: address, viewController: self.targetController)
                    self.targetController.present(vc, animated: true, completion: nil)
                case .failure(_):
                    self.targetController.showTipsMessage(message: "QR code expired".localized)
                    self.navigationController.popViewController(animated: true)
                }
                self.delegate?.scanCompleted(in: self)
            }
        } else if result.hasPrefix("/qrpay_info") {
            if !result.checkPayInfo() {
                targetController.showTipsMessage(message: "QR code expired".localized)
                navigationController.popViewController(animated: true)
                return
            }
            let address = session.account.currentAccount.address.description
            let sign = address + "&" + result.qrStringNonce()
            ScanProvider.shared.qrPayInfo(
                appname: result.qrStringAppName(),
                nonce: result.qrStringNonce(),
                address: address,
                sign: sign.md5String()
            ) {[weak self] (res) in
                guard let `self` = self else { return }
                switch res {
                case .success(let payData):
                    self.navigationController.popViewController(animated: false)
                    self.delegate?.scanPayment(for: payData, qrInfo: result, viewController: self.targetController)
                case .failure(_):
                    self.targetController.showTipsMessage(message: "QR code expired".localized)
                    self.navigationController.popViewController(animated: true)
                }
                self.delegate?.scanCompleted(in: self)
            }
        } else {
            let vc = ScanResultViewController()
            vc.resultString = result
            navigationController.pushViewController(vc, animated: true)
            delegate?.scanCompleted(in: self)
        }
    }
}


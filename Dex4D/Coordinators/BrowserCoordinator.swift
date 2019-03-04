//
//  BrowserCoordinator.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import WebKit

final class BrowserCoordinator: Coordinator {
    
    var coordinators: [Coordinator] = []
    
    let keystore: Keystore
    let account: WalletInfo
    let session: WalletSession
    
    let navigationController: NavigationController = NavigationController()
    
    lazy var rootViewController: BrowserViewController = {
        let vc = BrowserViewController(account: account)
        vc.delegate = self
        return vc
    }()
    
    let server = RPCServer()
    
    init(
        session: WalletSession,
        keystore: Keystore,
        tabBarItem: UITabBarItem
    ) {
        self.session = session
        self.keystore = keystore
        self.account = session.account
        rootViewController.tabBarItem = tabBarItem
    }
    
    func start() {
        navigationController.navigationBar.isHidden = true
        navigationController.viewControllers = [rootViewController]
    }
    
    private func addBookMarkOrHistory(type: BookmarkType, url: String, title: String?) {
        switch type {
        case .bookmark:
            let model = Bookmark(type: .bookmark, url: url, title: title)
            BookmarkStorage.shared.add(bookmarks: [model])
            break
        case .history:
            let model = Bookmark(type: .history, url: url, title: title)
            BookmarkStorage.shared.add(bookmarks: [model])
            break
        }
    }
    private func clearBrowserCache() {
        ClearCacheManage.clearBrowserCache()
        rootViewController.showTipsMessage(message: "Clear success".localized)
    }
}

extension BrowserCoordinator: BrowserViewControllerDelegate {
    
    func didVisitUrl(url: String, title: String?) {
        addBookMarkOrHistory(type: .history, url: url, title: title)
    }
    
    func didSelectCollectItem(sender: UIButton) {
        if let url = rootViewController.webView.url?.absoluteString {
            if sender.isSelected {
                sender.isSelected = !sender.isSelected
                BookmarkStorage.shared.deleteBookmark(url: url)
            } else {
                sender.isSelected = !sender.isSelected
                addBookMarkOrHistory(type: .bookmark, url: url, title: rootViewController.webView.title)
                //navigationController.showTipsMessage(message: "Add bookmark success".localized)
            }
        }
    }
    
    func didSelectMenuItem() {
        let alertController = UIAlertController (
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let action1 = UIAlertAction(
            title: "Reload".localized,
            style: .default
        ) { [weak self] _ in
            self?.rootViewController.startRequest()
        }
        let action2 = UIAlertAction(
            title: "Bookmark/History".localized,
            style: .default
        ) { [weak self] _ in
            let vc = BookmarkViewController()
            vc.presentViewController = self?.rootViewController
            let nvc = UINavigationController.init(rootViewController: vc)
            nvc.navigationBar.isHidden = true
            self?.rootViewController.present(nvc, animated: true, completion: nil)
        }
        let action3 = UIAlertAction(
            title: "Clear cache".localized,
            style: .default
        ) { [weak self] _ in
            self?.clearBrowserCache()
        }
        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        alertController.addAction(cancelAction)
        self.rootViewController.present(alertController, animated: true, completion: nil)
    }
    
    func didReceiveMessage(message: WKScriptMessage) {
        let decoder = JSONDecoder()
        guard let body = message.body as? [String: AnyObject],
            let jsonString = body.jsonString,
            let command = try? decoder.decode(DappCommand.self, from: jsonString.data(using: .utf8)!) else {
                return 
        }
        let callbackID = command.id
        let token = TokenObject(
            contract: server.priceID.description,
            name: server.name,
            coin: Coin.ethereum,
            type: .coin,
            symbol: server.symbol,
            decimals: server.decimals,
            value: "0",
            isCustom: false
        )
        let transfer = Transfer(server: server, type: .dapp(token, DAppRequester(title: nil, url: nil)))
        let action = DappAction.fromCommand(command, transfer: transfer)
        switch action {
        case .sendTransaction(let unconfirmedTransaction), .signTransaction(let unconfirmedTransaction):
            executeTransaction(account: account.currentAccount, action: action, transfer: transfer, transaction: unconfirmedTransaction, type: .signThenSend, server: server, callbackId: callbackID)
        default:
            break
        }
        
    }
    
    private func executeTransaction(account: Account, action: DappAction, transfer: Transfer, transaction: UnconfirmedTransaction, type: ConfirmType, server: RPCServer, callbackId: Int) {
        let nonceProvider = GetNonceProvider(storage: session.transactionsStorage, server: server, address: account.address)
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction,
            server: server,
            chainState: ChainState(server: server),
            nonceProvider: nonceProvider
        )
        let coordinator = ConfirmSendCoordinator(
            session: session,
            keystore: keystore,
            confirmType: .signThenSend,
            server: transfer.server,
            configurator: configurator,
            account: account,
            token: transfer.type.token,
            navigationController: navigationController
        )
        addCoordinator(coordinator)
        coordinator.didCompleted = { [weak self] (result, txHash)in
            guard let `self` = self else { return }
            switch result {
            case .success(let confirmResult):
                self.removeCoordinator(coordinator)
                switch confirmResult {
                case .sentTransaction(let transaction):
                    if let txHash = txHash {
                        let controller = SendSuccessController(
                            sentTransaction: transaction,
                            txHash: txHash,
                            token: transfer.type.token,
                            transfer: transfer
                        )
                        controller.callbackId = callbackId
                        controller.delegate = self
                        self.navigationController.pushViewController(controller, animated: true)
                    }
                case .signedTransaction: break
                }
            case .failure(let error):
                self.navigationController.topViewController?.showTipsMessage(message: error.localizedDescription)
            }
        }
    }
    
}

extension BrowserCoordinator: SendSuccessControllerDelegate {
    func didPressedDone(in viewController: SendSuccessController, sentTransaction: SentTransaction, callbackId: Int?) {
        if let callbackId = callbackId {
            let data = Data(hex: sentTransaction.id)
            let callback = DappCallback(id: callbackId, value: .sentTransaction(data))
            rootViewController.notifyFinish(callbackID: callbackId, value: .success(callback))
        }
    }
}


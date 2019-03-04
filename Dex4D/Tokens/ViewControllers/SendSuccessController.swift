//
//  SendSuccessController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/22.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

protocol SendSuccessControllerDelegate: class {
    func didPressedDone(in viewController: SendSuccessController, sentTransaction: SentTransaction, callbackId: Int?)
}

class SendSuccessController: BaseViewController {
    
    weak var delegate: SendSuccessControllerDelegate?
    
    private lazy var showSuccessView: ShowSendSuccessView = {
        let showSuccessView = R.nib.showSendSuccessView.firstView(owner: nil, options: nil)
        let view = showSuccessView ?? ShowSendSuccessView()
        view.delegate = self
        return view
    }()
    
    let viewModel: ShowSendSuccessViewModel
    
    let sentTransaction: SentTransaction
    let txHash: String
    let token: TokenObject
    let transfer: Transfer
    
    var callbackId: Int?
    
    init(
        sentTransaction: SentTransaction,
        txHash: String,
        token: TokenObject,
        transfer: Transfer
    ) {
        self.sentTransaction = sentTransaction
        self.txHash = txHash
        self.token = token
        self.transfer = transfer
        viewModel = ShowSendSuccessViewModel(
            sentTransaction: sentTransaction,
            txHash: txHash,
            token: token,
            transfer: transfer
        )
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        navigationBar.setRightButtonTitle(title: "Done".localized, target: self, action: #selector(self.done))
        
        view.addSubview(showSuccessView)
        showSuccessView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(350)
        }
        
        showSuccessView.configure(with: viewModel)
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated:Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @objc func done() {
        navigationController?.popToRootViewController(animated: true)
        delegate?.didPressedDone(in: self, sentTransaction: sentTransaction, callbackId: callbackId)
    }
}

extension SendSuccessController: ShowSendSuccessViewDelegate {
    func didSelectTxHashButton() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator {
            print(Dex4DUrls.hash + viewModel.txHash)
            main.browserCoordinator.rootViewController.urlString = Dex4DUrls.hash + viewModel.txHash
            main.tabBarController.selectedIndex = 2
            navigationController?.popToRootViewController(animated: false)
        }
    }
}

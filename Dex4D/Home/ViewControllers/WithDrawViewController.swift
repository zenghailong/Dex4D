//
//  Dex4DTradeViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/28.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt

protocol WithDrawViewControllerDelegate: class {
    func didCancelWithdraw(in controller: UIViewController)
    func didPressConfirm(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        amount: String,
        in viewController: UIViewController
    )
}

class WithDrawViewController: BaseViewController {
    
    weak var delegate: WithDrawViewControllerDelegate?
    
    let accountViewModel: DexAccountViewModel
    let chainState: ChainState
    let tokensStorage: TokensDataStore
    
    lazy var withdrawView: WithdrawView = {
        let withdraw = WithdrawView(
            style: .withdraw,
            chainState: chainState,
            navigationController: self.navigationController ?? UINavigationController(),
            accountViewModel: accountViewModel
        )
        withdraw.delegate = self
        return withdraw
    }()
    
    init(
        accountViewModel: DexAccountViewModel,
        chainState: ChainState,
        tokensStorage: TokensDataStore
    ) {
        self.accountViewModel = accountViewModel
        self.chainState = chainState
        self.tokensStorage = tokensStorage
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "Withdraw".localized
        
        view.addSubview(withdrawView)
        withdrawView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(withdrawView.bounds.size.height)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    deinit {
        delegate?.didCancelWithdraw(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WithDrawViewController: WithdrawViewDelegate {
    
    func didPressedWithdraw(for view: WithdrawView) {
        guard view.isInputValid == true else {
            showTipsMessage(message: Errors.wrongInput.errorDescription)
            return
        }
        let transfer = Dex4DTransfer(server: chainState.server, type: .token)
        let parsedValue: BigInt? = {
            switch transfer.type {
            case .ether:
                return EtherNumberFormatter.full.number(from: view.transferAmount, units: .ether)
            case .token:
                return EtherNumberFormatter.full.number(from: view.transferAmount, decimals: DexConfig.decimals)
            }
        }()
        guard let value = parsedValue else {
            showTipsMessage(message: Errors.invalidAmount.errorDescription)
            return
        }
        guard let selectedToken = view.selectedToken else { return }
        let transferActionType = D4DTransferActionType.withdraw(token: selectedToken.name)
        let transaction = DexUnconfirmedTransaction(
            transfer: transfer,
            value: value,
            to: EthereumAddress(string: DexConfig.dex_protocol),
            data: Data(),
            gasLimit: .none,
            gasPrice: chainState.gasPrice,
            nonce: .none
        )
        let token = accountViewModel.tokenObjects.filter { $0.name == selectedToken.name }.first
        if let token = token {
            delegate?.didPressConfirm(
                transaction: transaction,
                transfer: transfer,
                token: token,
                type: transferActionType,
                amount: view.tradeTextField.text!,
                in: self
            )
        }
    }

}


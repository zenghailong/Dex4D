//
//  ReferralLockViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt

protocol AuthorityPayViewControllerDelegate: class {
    func pushToNickName(count: Double, chainState: ChainState)
    func didPressPayForSwap(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        chainState: ChainState,
        in viewController: UIViewController
    )
}

class AuthorityPayViewController: BaseViewController {
    
    weak var delegate: AuthorityPayViewControllerDelegate?
    
    let viewModel: AuthorityPayViewModel
    let account: WalletInfo
    
    let chainState = ChainState(server: RPCServer())
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.titleLabelText
        label.font = UIFont.defaultFont(size: 16)
        label.textColor = .white
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var payDex4DView: PayDex4DView = {
        let view = PayDex4DView(viewModel: viewModel)
        view.delegate = self
        return view
    }()
    
    private lazy var payETHView: PayETHView = {
        let view = PayETHView(viewModel: viewModel)
        view.delegate = self
        return view
    }()
    
    private lazy var payBottomView: PayBottomView = {
        let view = PayBottomView()
        return view
    }()
    
    init(
        account: WalletInfo,
        operation: AuthorityOperation.Operation,
        tokensStorage: TokensDataStore
    ) {
        self.account = account
        self.viewModel = AuthorityPayViewModel(
            account: account,
            operation: operation,
            tokensStorage: tokensStorage
        )
        super.init(nibName: nil, bundle: nil)
        viewModel.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.authorityOperation.stringValue.localized
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }

        let height = viewModel.authorityOperation.operation == .referral ? 250 : 150
        view.addSubview(payDex4DView)
        payDex4DView.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(height)
        }
        
        viewModel.setDefaultValue()
        NotificationCenter.default.addObserver(self, selector: #selector(self.autorityPaySuccess), name: NotificationNames.autorityPaySuccess, object: nil)
    }
    
    @objc private func autorityPaySuccess() {
        viewModel.authorityOperation.authority = .pending
        authorityValueChanged()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkBottomView() {
        payBottomView.removeFromSuperview()
        payETHView.removeFromSuperview()
        if viewModel.authorityOperation.authority == .forever {
            payBottomView.hideTitleLabel()
            payBottomView.tipsLabel.attributedText = viewModel.foreverLabelText
            view.addSubview(payBottomView)
            payBottomView.snp.makeConstraints { (make) in
                make.top.equalTo(payDex4DView.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.height.equalTo(90)
            }
        } else if viewModel.authorityOperation.authority == .pending {
            payBottomView.showTitleLabel()
            payBottomView.bottomTitleLabel.text = viewModel.pendingTitleLabelText
            payBottomView.tipsLabel.attributedText = viewModel.pendingLabelText
            view.addSubview(payBottomView)
            payBottomView.snp.makeConstraints { (make) in
                make.top.equalTo(payDex4DView.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.height.equalTo(90)
            }
        } else if viewModel.authorityOperation.authority == .none {
            view.addSubview(payETHView)
            payETHView.snp.makeConstraints { (make) in
                make.top.equalTo(payDex4DView.snp.bottom).offset(20)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.height.equalTo(190)
            }
        }
    }
}

extension AuthorityPayViewController: PayDex4DViewDelegate {
    func didSelectDex4DSubmitButton() {
        let vc = ShowQRCodeViewController(address: account.currentAccount.address.description, showType: .referral)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AuthorityPayViewController: PayETHViewDelegate {
    func didSelectETHSubmitButton() {
        if viewModel.ethCount == 0 {
            return
        }
        if viewModel.ethBalance < viewModel.ethCount {
            showTipsMessage(message: "Insufficient tokens".localized)
            return
        }
        switch viewModel.authorityOperation.operation {
        case .referral:
            delegate?.pushToNickName(count: viewModel.ethCount, chainState: chainState)
        case .swap:
            let transfer = Dex4DTransfer(server: chainState.server, type: .ether)
            let parsedValue: BigInt = EtherNumberFormatter.full.number(from: String(viewModel.ethCount), units: .ether) ?? BigInt(0)
            let transferActionType = D4DTransferActionType.buySwapAuthority
            let transaction = DexUnconfirmedTransaction(
                transfer: transfer,
                value: parsedValue,
                to: EthereumAddress(string: DexConfig.dex_referraler),
                data: Data(),
                gasLimit: .none,
                gasPrice: chainState.gasPrice,
                nonce: .none
            )
            delegate?.didPressPayForSwap(
                transaction: transaction,
                transfer: transfer,
                type: transferActionType,
                chainState: chainState,
                in: self
            )
        }
    }
}

extension AuthorityPayViewController: AuthorityPayViewModelDelegate {
    func ethBalanceValueChanged() {
        titleLabel.text = viewModel.titleLabelText
        payETHView.ethBalanceValueChanged()
    }
    func ethCountValueChanged() {
        payETHView.ethCountValueChanged()
    }
    func dex4DBalanceValueChanged() {
        payDex4DView.dex4DBalanceValueChanged()
    }
    func authorityValueChanged() {
        checkBottomView()
        payDex4DView.authorityValueChanged()
    }
}


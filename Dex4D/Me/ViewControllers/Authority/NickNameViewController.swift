//
//  NickNameViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/31.
//  Copyright © 2018 龙. All rights reserved.
//
import UIKit
import BigInt

protocol NickNameViewControllerDelegate: class {
    func didPressPay(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        type: D4DTransferActionType,
        chainState: ChainState,
        in viewController: UIViewController
    )
}

class NickNameViewController: BaseViewController {
    
    weak var delegate: NickNameViewControllerDelegate?
    
    let count: Double
    let chainState: ChainState
    let viewModel = NickNameViewModel()
    
    private lazy var descriptionLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.textAlignment = .left
        descLabel.textColor = viewModel.descriptionTextColor
        descLabel.font = viewModel.descriptionFont
        descLabel.text = viewModel.description
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    private lazy var textFieldView: CustomTextFieldView = {
        let view = CustomTextFieldView()
        view.backgroundColor = Colors.cellBackground
        view.textField.textColor = .white
        view.textField.font = UIFont.defaultFont(size: 14)
        return view
    }()
    
    private lazy var continueButton: UIButton = {
        let continueButton = UIButton(type: .custom)
        continueButton.setTitle(viewModel.continueBtnText, for: .normal)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.backgroundColor = Colors.globalColor
        continueButton.titleLabel?.font = viewModel.continueBtnTextFont
        continueButton.layer.cornerRadius = Constants.BaseButtonHeight / 2
        continueButton.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        return continueButton
    }()
    
    init(count: Double, chainState: ChainState) {
        self.count = count
        self.chainState = chainState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setCustomNavigationbar()
        super.setBackButton()
        navigationBar.titleText = viewModel.titleText
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 10)
            make.left.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.height.equalTo(53)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldView.snp.bottom).offset(50)
            make.height.equalTo(Constants.BaseButtonHeight)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldView.textField.becomeFirstResponder()
    }
    
    @objc private func buttonAction() {
        if textFieldView.text == "" {
            showTipsMessage(message: String(format: "%@ can't be empty".localized, "Referral address".localized))
            return
        }
        if !textFieldView.text!.isLegalNickName() {
            showTipsMessage(message: String(format: "%@ is illegal".localized, "Referral address".localized))
            return
        }
        Dex4DProvider.shared.isStandardDex4DUserName(username: textFieldView.text!) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let flag):
                if flag {
                    self.pushToSend(nickname: self.textFieldView.text!)
                } else {
                    self.showTipsMessage(message: String(format: "%@ already exists".localized, "Referral address".localized))
                }
                break
            case .failure(_):
                break
            }
        }
    }
    
    private func pushToSend(nickname: String) {
        let transfer = Dex4DTransfer(server: chainState.server, type: .ether)
        let parsedValue: BigInt = EtherNumberFormatter.full.number(from: String(count), units: .ether) ?? BigInt(0)
        let transferActionType = D4DTransferActionType.buyReferralAuthority(nick: nickname)
        let transaction = DexUnconfirmedTransaction(
            transfer: transfer,
            value: parsedValue,
            to: EthereumAddress(string: DexConfig.dex_referraler),
            data: Data(),
            gasLimit: .none,
            gasPrice: chainState.gasPrice,
            nonce: .none
        )
        delegate?.didPressPay(
            transaction: transaction,
            transfer: transfer,
            type: transferActionType,
            chainState: chainState,
            in: self
        )
    }
}

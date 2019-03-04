//
//  PayConfirmViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/15.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Result

protocol PayConfirmViewControllerDelegate: class {
    func didCancelToSend()
}

class PayConfirmViewController: BaseViewController {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.scan_pay()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.titleText
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    private lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = viewModel.amountText
        label.font = UIFont.defaultFont(size: 18)
        label.textAlignment = .center
        return label
    }()
    private lazy var waitingLabel: UILabel = {
        let label = UILabel()
        label.text = "Waiting".localized
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fromTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "From".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var fromValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.from
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    private lazy var toTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "To".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var toValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.to
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    private lazy var gasTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "GAS consumption".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var gasValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.gas
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Colors.globalColor
        button.setTitle("Confirm".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(submitAction), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Colors.globalColor
        button.setTitle("Reject".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(cancelButtonAction), for: .touchUpInside)
        return button
    }()
    
    lazy var sendTransactionCoordinator: DexSendTransferCoordinator = {
        let coordinator = DexSendTransferCoordinator(
            keystore: keystore,
            configurator: configurator,
            isAuthorized: isAuthorized,
            method: method,
            viewController: self
        )
        coordinator.delegate = self
        return coordinator
    }()
    
    var sendContractCoordinator: DexSendTransferCoordinator?
    
    weak var delegate: PayConfirmViewControllerDelegate?
    
    var didCompleted: ((Result<ConfirmResult, AnyError>, _ txHash: String?, _ isAuthorized: Bool) -> Void)?
    
    private let keystore: Keystore
    let session: WalletSession
    let configurator: DexTransactionConfigurator
    let account: Account
    let isAuthCompleted: Bool
    let isAuthorized: Bool
    let method: PayMethod
    let viewModel: DexConfirmViewModel
    
    init(
        session: WalletSession,
        keystore: Keystore,
        configurator: DexTransactionConfigurator,
        account: Account,
        isAuthCompleted: Bool = false,
        isAuthorized: Bool = false,
        method: PayMethod
    ) {
        self.session = session
        self.keystore = keystore
        self.account = account
        self.configurator = configurator
        self.isAuthCompleted = isAuthCompleted
        self.isAuthorized = isAuthorized
        self.method = method
        self.viewModel = DexConfirmViewModel(configurator: configurator)
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func backButtonAction() {
        dismissAction()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        addSubviews()
    }
    
    private func dismissAction() {
        switch method {
        case .scan(let qrInfo):
            viewModel.sendCancelRequest(qrInfo: qrInfo)
        default: break
        }
        dismiss(animated: true, completion: nil)
        delegate?.didCancelToSend()
    }
    
    @objc private func submitAction() {
        sendTransactionCoordinator.fetch()
    }
    
    @objc private func cancelButtonAction() {
        dismissAction()
    }
    
    private func handleApproveResult() {
        let transaction = DexUnconfirmedTransaction(
            transfer: configurator.transaction.transfer,
            value: configurator.transaction.value,
            to: EthereumAddress(string: DexConfig.dex_protocol),
            data: configurator.transaction.data,
            gasLimit: .none,
            gasPrice: configurator.chainState.gasPrice,
            nonce: .none
        )
        let sendConfigurator = DexTransactionConfigurator(
            session: session,
            account: session.account.currentAccount,
            transaction: transaction,
            chainState: configurator.chainState,
            type: configurator.type,
            token: configurator.token,
            nonceProvider: configurator.nonceProvider
        )
        sendContractCoordinator = DexSendTransferCoordinator(
            keystore: keystore,
            configurator: sendConfigurator,
            isAuthCompleted: true,
            method: method,
            viewController: self
        )
        sendContractCoordinator?.delegate = self
        sendContractCoordinator?.fetch()
    }
    
    func addSubviews() {
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 44)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        view.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        view.addSubview(waitingLabel)
        waitingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(amountLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: "383847")
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(waitingLabel.snp.bottom).offset(30 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        view.addSubview(fromTitleLabel)
        fromTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(Constants.leftPadding)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(fromValueLabel)
        fromValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fromTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        view.addSubview(toTitleLabel)
        toTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fromTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(toValueLabel)
        toValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(toTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        view.addSubview(gasTitleLabel)
        gasTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(toTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(gasValueLabel)
        gasValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(gasTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(gasTitleLabel.snp.bottom).offset(70)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.BaseButtonHeight)
        }
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(submitButton.snp.bottom).offset(32)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.BaseButtonHeight)
        }
    }
}

extension PayConfirmViewController: DexSendTransferCoordinatorDeleagte {
    func didCompletedToSend(result: Result<ConfirmResult, AnyError>, _ txHash: String?, isAuthorized: Bool) {
        switch result {
        case .success(_):
            if isAuthorized {
                handleApproveResult()
            } else {
                dismiss(animated: true) {[weak self] in
                    self?.didCompleted?(result, txHash, isAuthorized)
                }
            }
        case .failure(_):
            showTipsMessage(message: "Send failure".localized)
        }
    }
}


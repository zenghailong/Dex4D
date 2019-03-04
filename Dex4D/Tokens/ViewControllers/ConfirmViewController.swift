//
//  ConfirmViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/20.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import Result

protocol ConfirmViewControllerDelegate: class {
    func didCancelToSend()
}

class ConfirmViewController: BaseViewController {
    
    weak var delegate: ConfirmViewControllerDelegate?
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.scan_pay()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = createTextLabel(color: Colors.textTips, font: UIFont.defaultFont(size: 14), textAlignment: .center)
        switch configurator.transaction.transfer.type {
        case .ether, .token: label.text = "Send amount".localized
        case .dapp: break
        }
        return label
    }()
    
    private lazy var amountLabel: UILabel = {
        let label = createTextLabel(color: UIColor.white, font: UIFont.defaultFont(size: 18), textAlignment: .center)
        switch configurator.transaction.transfer.type {
        case .ether, .token: label.text = viewModel.amount
        case .dapp: break
        }
        return label
    }()
    
    private lazy var waitingLabel: UILabel = {
        let label = createTextLabel(color: Colors.textTips, font: UIFont.defaultFont(size: 14), textAlignment: .center)
        label.text = "Waiting".localized
        return label
    }()
    
    let line: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = UIColor(hex: "383847")
        return lineView
    }()
    
    private lazy var fromTitleLabel: UILabel = {
        let label = createTextLabel(color: UIColor.white, font: UIFont.defaultFont(size: 14), textAlignment: .left)
        label.text = "From".localized
        return label
    }()
    
    private lazy var fromValueLabel: UILabel = {
        let label = createTextLabel(color: Colors.textTips, font: UIFont.defaultFont(size: 14), textAlignment: .right)
        label.text = viewModel.from
        return label
    }()
    
    private lazy var toTitleLabel: UILabel = {
        let label = createTextLabel(color: UIColor.white, font: UIFont.defaultFont(size: 14), textAlignment: .left)
        label.text = "To".localized
        return label
    }()
    
    private lazy var toValueLabel: UILabel = {
        let label = createTextLabel(color: Colors.textTips, font: UIFont.defaultFont(size: 14), textAlignment: .right)
        label.text = viewModel.to
        return label
    }()
    
    private lazy var gasTitleLabel: UILabel = {
        let label = createTextLabel(color: UIColor.white, font: UIFont.defaultFont(size: 14), textAlignment: .left)
        label.text = "GAS consumption".localized
        return label
    }()
    
    private lazy var gasValueLabel: UILabel = {
        let label = createTextLabel(color: Colors.textTips, font: UIFont.defaultFont(size: 14), textAlignment: .right)
        label.text = viewModel.gas
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
        button.addTarget(self, action: #selector(submitButtonAction), for: .touchUpInside)
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
    
    private lazy var headerStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            amountLabel,
            waitingLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        return stackView
    }()
    lazy var sendTransactionCoordinator: SendTransactionCoordinator = {
        let coordinator = SendTransactionCoordinator(
            keystore: keystore,
            confirmType: confirmType,
            configurator: configurator,
            account: account,
            viewController: self
        )
        coordinator.delegate = self
        return coordinator
    }()
    
    var didCompleted: ((Result<ConfirmResult, AnyError>, _ txHash: String?) -> Void)?
    
    private let keystore: Keystore
    
    let session: WalletSession
    let confirmType: ConfirmType
    let server: RPCServer
    let configurator: TransactionConfigurator
    let account: Account
    let token: TokenObject
    let viewModel: ConfirmSendViewModel
    
    init(
        session: WalletSession,
        keystore: Keystore,
        confirmType: ConfirmType,
        server: RPCServer,
        configurator: TransactionConfigurator,
        account: Account,
        token: TokenObject
    ) {
        self.session = session
        self.keystore = keystore
        self.confirmType = confirmType
        self.server = server
        self.account = account
        self.configurator = configurator
        self.token = token
        self.viewModel = ConfirmSendViewModel(configurator: configurator, account: account, token: token)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
        }
        view.addSubview(headerStack)
        headerStack.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(18)
            make.left.right.equalToSuperview()
            make.height.equalTo(70)
        }
        addSubviews()
        let footerStack = UIStackView(arrangedSubviews: [
            submitButton,
            cancelButton
        ])
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        footerStack.axis = .vertical
        footerStack.spacing = 32
        view.addSubview(footerStack)
        NSLayoutConstraint.activate([
            footerStack.topAnchor.constraint(equalTo: gasValueLabel.bottomAnchor, constant: 70),
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            footerStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerStack.heightAnchor.constraint(equalToConstant: 116),
            submitButton.heightAnchor.constraint(equalToConstant: Constants.BaseButtonHeight)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // iconImageView.startRotationAnimation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //iconImageView.stopRotationAnimation()
    }
    
    override func backButtonAction() {
        delegate?.didCancelToSend()
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitButtonAction() {
        sendTransactionCoordinator.fetch()
    }
    
    @objc private func cancelButtonAction() {
        delegate?.didCancelToSend()
        dismiss(animated: true, completion: nil)
    }
    
    private func createTextLabel(color: UIColor, font: UIFont, textAlignment: NSTextAlignment) -> UILabel {
        let label = UILabel()
        label.textColor = color
        label.font = font
        label.textAlignment = textAlignment
        return label
    }
    
    private func addSubviews() {
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(headerStack.snp.bottom).offset(30)
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
    }
}

extension ConfirmViewController: SendTransactionCoordinatorDeleagte {
    func didCompletedToSend(result: Result<ConfirmResult, AnyError>, _ txHash: String?) {
        dismiss(animated: true) {[weak self] in
            self?.didCompleted?(result, txHash)
        }
    }
}

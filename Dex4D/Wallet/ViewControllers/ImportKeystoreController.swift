//
//  ImportKeystoreController.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol ImportKeystoreControllerDelegate: class {
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportKeystoreController)
}

class ImportKeystoreController: BaseViewController {
    
    weak var delegate: ImportKeystoreControllerDelegate?
    
    let keystore: Keystore
    let viewModel: ImportKeystoreViewModel
    
    private lazy var titleTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.font = viewModel.titleFont
        textLabel.text = viewModel.titleText
        textLabel.numberOfLines = 0
        return textLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.textAlignment = .left
        descLabel.textColor = viewModel.descriptionTextColor
        descLabel.font = viewModel.descriptionFont
        descLabel.text = viewModel.description
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    private lazy var inputKeystoreView: InputKeystoreView = {
        let inputKeystoreView = InputKeystoreView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth - 2 * Constants.leftPadding, height: 120))
        return inputKeystoreView
    }()
    
    private lazy var inputPasswordView: InputkeystorePasswordView = {
        let inputPasswordView = InputkeystorePasswordView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth - 2 * Constants.leftPadding, height: 53))
        return inputPasswordView
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(viewModel.finishedBtnText, for: .normal)
        button.setTitleColor(viewModel.inValidFinishedTextColor, for: .normal)
        button.backgroundColor = viewModel.inValidFinishedBtnColor
        button.titleLabel?.font = viewModel.finishedBtnTextFont
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.importKeystore), for: .touchUpInside)
        return button
    }()
    
    
    init(keystore: Keystore, viewModel: ImportKeystoreViewModel) {
        self.keystore = keystore
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        setupUI()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        inputKeystoreView.textDidChangedBlock = {[weak self] textView in
            guard let `self` = self else { return }
            if !textView.text.isEmpty && self.inputPasswordView.textField.text?.isEmpty == false {
                self.finishButton.isEnabled = true
                self.finishButton.backgroundColor = Colors.globalColor
                self.finishButton.setTitleColor(.white, for: .normal)
            } else {
                self.finishButton.isEnabled = false
                self.finishButton.backgroundColor = self.viewModel.inValidFinishedBtnColor
                self.finishButton.setTitleColor(self.viewModel.inValidFinishedTextColor, for: .normal)
            }
        }
        inputPasswordView.textDidChangedBlock = {[weak self] textField in
            guard let `self` = self else { return }
            if !self.inputKeystoreView.textView.text.isEmpty && textField.text?.isEmpty == false {
                self.finishButton.isEnabled = true
                self.finishButton.backgroundColor = Colors.globalColor
                self.finishButton.setTitleColor(.white, for: .normal)
            } else {
                self.finishButton.isEnabled = false
                self.finishButton.backgroundColor = self.viewModel.inValidFinishedBtnColor
                self.finishButton.setTitleColor(self.viewModel.inValidFinishedTextColor, for: .normal)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        inputKeystoreView.textView.resignFirstResponder()
        inputPasswordView.textField.resignFirstResponder()
    }
    
    @objc func importKeystore() {
        let keystoreInput = inputKeystoreView.textView.text.trimmed
        let password = inputPasswordView.textField.text?.trimmed ?? ""
        displayLoading(text: "Importing wallet...".localized, animated: false)
        importWallet(for: .keystore(string: keystoreInput, password: password), name: "MainWallet")
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if inputKeystoreView.textView.isFirstResponder {
                inputKeystoreView.textView.resignFirstResponder()
            }
            if inputPasswordView.textField.isFirstResponder {
                inputPasswordView.textField.resignFirstResponder()
            }
        }
        sender.cancelsTouchesInView = false
    }
    
    func importWallet(for type: ImportType, name: String) {
        keystore.importWallet(type: type, coin: .ethereum) {[weak self] result in
            guard let `self` = self else { return }
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                print(account.accounts.first?.address ?? "")
                self.didImport(account: account, name: name)
            case .failure(let error):
                self.showTipsMessage(message: "Import wallet failed".localized)
                print(error.localizedDescription)
            }
        }
    }
    
    func didImport(account: WalletInfo, name: String) {
        delegate?.didImportAccount(account: account, fields: [.name(name)], in: self)
        Dex4DProvider.shared.loginLog(address: account.currentAccount.address.description, type: "keystore")
    }
    
    private func setupUI() {
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(34)
            make.left.equalToSuperview().offset(38)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(inputKeystoreView)
        inputKeystoreView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(44)
            make.centerX.equalToSuperview()
            make.height.equalTo(160)
        }
        
        view.addSubview(inputPasswordView)
        inputPasswordView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.top.equalTo(inputKeystoreView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(53)
        }
        
        view.addSubview(finishButton)
        finishButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputPasswordView.snp.bottom).offset(50)
            make.height.equalTo(Constants.BaseButtonHeight)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

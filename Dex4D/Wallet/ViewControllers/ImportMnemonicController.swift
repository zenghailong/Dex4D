//
//  ImportMnemonicController.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol ImportMnemonicControllerDelegate: class {
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportMnemonicController)
}

class ImportMnemonicController: BaseViewController {

    weak var delegate: ImportMnemonicControllerDelegate?
    
    let keystore: Keystore
    let viewModel: ImportMnemonicViewModel
    
    init(keystore: Keystore, viewModel: ImportMnemonicViewModel) {
        self.keystore = keystore
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
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
    
    private lazy var inputMnemonicView: InputMnemonicView = {
        let inputMnemonicView = InputMnemonicView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth - 2 * Constants.leftPadding, height: 120))
        inputMnemonicView.textView.becomeFirstResponder()
        return inputMnemonicView
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(viewModel.inValidConfirmBtnText, for: .normal)
        button.setTitleColor(viewModel.inValidConfirmTextColor, for: .normal)
        button.backgroundColor = viewModel.inValidConfirmBtnColor
        button.titleLabel?.font = viewModel.confirmBtnTextFont
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.isEnabled = false
        button.addTarget(self, action: #selector(self.importMnemonic), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        setupUI()
        inputMnemonicView.textDidChangedBlock = {[weak self] textView in
            guard let `self` = self else { return }
            if textView.text.count != 0 {
                self.confirmButton.isEnabled = true
                self.confirmButton.backgroundColor = Colors.globalColor
                self.confirmButton.setTitleColor(.white, for: .normal)
            } else {
                self.confirmButton.isEnabled = false
                self.confirmButton.backgroundColor = self.viewModel.inValidConfirmBtnColor
                self.confirmButton.setTitleColor(self.viewModel.inValidConfirmTextColor, for: .normal)
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        inputMnemonicView.textView.resignFirstResponder()
    }
    
    @objc func importMnemonic() {
        let password = ""
        let mnemonicInput = inputMnemonicView.textView.text.trimmed
        let words = mnemonicInput.components(separatedBy: " ").map { $0.trimmed.lowercased() }
        displayLoading(text: "Importing wallet...", animated: false)
        let enterType = ImportType.mnemonic(words: words, password: password, derivationPath: Coin.ethereum.derivationPath(at: 0))
        keystore.importWallet(type: enterType, coin: .ethereum) { result in
            switch result {
            case .success(let account):
                self.addWallets(wallet: account)
                self.hideLoading(animated: false)
                self.didImport(account: account)
            case .failure(_):
                DispatchQueue.main.async {
                    self.hideLoading(animated: false)
                    self.showTipsMessage(message: "Import wallet failed".localized)
                }
            }
        }
    }
    
    func didImport(account: WalletInfo) {
        delegate?.didImportAccount(account: account, fields: [.name("MainWallet")], in: self)
        Dex4DProvider.shared.loginLog(address: account.currentAccount.address.description, type: "mword")
    }
    
    @discardableResult
    func addWallets(wallet: WalletInfo) -> Bool {
        // Create coins based on supported networks
        guard let w = wallet.currentWallet else {
            return false
        }
        let derivationPaths = Config.current.servers.map { $0.derivationPath(at: 0) }
        let _ = keystore.addAccount(to: w, derivationPaths: derivationPaths)
        return true
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
        
        view.addSubview(inputMnemonicView)
        inputMnemonicView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.top.equalTo(descriptionLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(inputMnemonicView.snp.bottom).offset(50)
            make.height.equalTo(Constants.BaseButtonHeight)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

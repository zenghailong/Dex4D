//
//  KeystoreViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/26.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class KeystoreViewController: BaseViewController {
    
    let password: String
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Your new keystore file in JSON format generate with password you just input as shown below. Please keep it in safe place. You can import your wallet with this keystore file and it's password".localized.toAttributedString()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 12)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var keystoreView: UITextView = {
        let view = UITextView()
        view.backgroundColor = Colors.cellBackground
        view.attributedText = "".toAttributedString()
        view.textColor = .white
        view.font = UIFont.defaultFont(size: 12)
        view.textContainerInset = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        view.isEditable = false
        return view
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.setTitle("Copy".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(copyAction), for: .touchUpInside)
        return button
    }()
    
    let keystore: Keystore
    let account: WalletInfo
    
    init(
        password: String,
        keystore: Keystore,
        account: WalletInfo
    ) {
        self.password = password
        self.keystore = keystore
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "Keystore".localized
        
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: GenerateEnterPasswordController.self) == false &&
                $0.isKind(of: KeystorePasswordViewController.self) == false
            }
        }
        
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 30 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(40)
            make.right.equalToSuperview().offset(-40)
        }
        
        view.addSubview(keystoreView)
        keystoreView.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(40 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(Constants.ScreenHeight / 3)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(keystoreView.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(42)
        }
        
        guard let wallet = WalletManager.shared.currentWallet else {
            return
        }
        guard let oldPassword = KeyChainManager.shared.getValue(for: wallet.identifier) else {
            return
        }
        displayLoading()
        WalletManager.shared.keystore.export(wallet: wallet, password: oldPassword, newPassword: password) {[weak self] (result) in
            self?.hideLoading()
            switch result {
            case .success(let data):
                self?.keystoreView.attributedText = data.toAttributedString()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func copyAction() {
        UIPasteboard.general.string = keystoreView.text
        showTipsMessage(message: "Copied".localized)
    }
    
}

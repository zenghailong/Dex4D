//
//  WelcomeViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import SnapKit

protocol WelcomeViewControllerDelegate: class {
    func didPressCreateWallet()
    func didPressImportWallet()
}

final class WelcomeViewController: BaseViewController {
    
    weak var delegate: WelcomeViewControllerDelegate?
    
    private lazy var logoImageView: UIImageView = {
        let logoView = UIImageView(image: R.image.welcome_logo())
        return logoView
    }()
    
    private lazy var logoTextView: UIImageView = {
    let logoView = UIImageView(image: R.image.logo_text())
    return logoView
    }()
    
    let importWalletButton: UIButton = {
        let importButton = UIButton(type: .custom)
        importButton.backgroundColor = Colors.globalColor
        importButton.setTitle("Restore".localized, for: .normal)
        importButton.setTitleColor(.white, for: .normal)
        importButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        importButton.layer.cornerRadius = Constants.BaseButtonHeight / 2
        importButton.layer.masksToBounds = true
        return importButton
    }()
    
    let createWalletButton: UIButton = {
        let createButton = UIButton(type: .custom)
        createButton.backgroundColor = Colors.globalColor
        createButton.setTitle("Start".localized, for: .normal)
        createButton.setTitleColor(.white, for: .normal)
        createButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        createButton.layer.cornerRadius = Constants.BaseButtonHeight / 2
        createButton.layer.masksToBounds = true
        createButton.addTarget(self, action: #selector(self), for: .touchDown)
        createButton.addTarget(self, action: #selector(self), for: .touchCancel)
        return createButton
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150 * Constants.ScaleHeight)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(logoTextView)
        logoTextView.snp.makeConstraints { (make) in
            make.top.equalTo(logoImageView.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        
        let stackView = UIStackView(arrangedSubviews: [
               importWalletButton,
               createWalletButton
            ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 33
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(63 * Constants.ScaleHeight + Constants.BottomBarHeight))
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(117)
        }
        NSLayoutConstraint.activate([
            importWalletButton.heightAnchor.constraint(equalToConstant: Constants.BaseButtonHeight)
        ])
        createWalletButton.addTarget(self, action: #selector(WelcomeViewController.start), for: .touchUpInside)
        importWalletButton.addTarget(self, action: #selector(WelcomeViewController.importWallet), for: .touchUpInside)
    }
    
    @objc fileprivate func start() {
        delegate?.didPressCreateWallet()
    }
    
    @objc fileprivate func importWallet() {
        delegate?.didPressImportWallet()
    }
    
}

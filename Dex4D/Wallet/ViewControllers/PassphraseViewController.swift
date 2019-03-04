//
//  PassphraseViewController.swift
//  Dex4D
//
//  Created by zeng hai long on 14/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol PassphraseViewControllerDelegate: class {
    func didPressedContinueButton(account: Wallet, words: [String], in viewController: PassphraseViewController)
    func didSkipToBackupPhrase(account: Wallet, in viewController: PassphraseViewController)
    func didCancel(in viewController: PassphraseViewController)
}

class PassphraseViewController: BaseViewController {
    
    weak var delegate: PassphraseViewControllerDelegate?
    let viewModel: PassphraseViewModel
    let account: Wallet
    let words: [String]
    let option: PassphraseOption
    
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
    
    private lazy var warningLabel: UILabel = {
        let warningLabel = UILabel()
        warningLabel.textAlignment = .left
        warningLabel.textColor = viewModel.descriptionTextColor
        warningLabel.font = viewModel.descriptionFont
        warningLabel.text = viewModel.warningText
        warningLabel.numberOfLines = 0
        return warningLabel
    }()
    
    private lazy var continueButton: UIButton = {
        let continueButton = UIButton(type: .custom)
        continueButton.setTitle(viewModel.continueBtnText, for: .normal)
        continueButton.setTitleColor(UIColor.white, for: .normal)
        continueButton.backgroundColor = Colors.globalColor
        continueButton.titleLabel?.font = viewModel.continueBtnTextFont
        continueButton.layer.cornerRadius = Constants.BaseButtonHeight / 2
        return continueButton
    }()
    
    private lazy var remindButton: UIButton = {
        let remindButton = UIButton(type: .custom)
        remindButton.setTitle(viewModel.remindBtnText, for: .normal)
        remindButton.setTitleColor(Colors.globalColor, for: .normal)
        remindButton.titleLabel?.font = viewModel.remindBtnTextFont
        return remindButton
    }()
    
    let lineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = Colors.globalColor
        return lineView
    }()
    
    private lazy var passphraseView: PassphraseView = {
        let passphraseView = PassphraseView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth - 2 * Constants.leftPadding, height: 180), words: self.words)
        passphraseView.backgroundColor = .clear
        passphraseView.layer.cornerRadius = 5
        passphraseView.layer.masksToBounds = true
        return passphraseView
    }()
    
    init(
        account: Wallet,
        words: [String],
        option: PassphraseOption
    ) {
        self.option = option
        self.viewModel = PassphraseViewModel(option: option)
        self.account = account
        self.words = words
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setCustomNavigationbar()
        super.setBackButton()
        
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: GenerateEnterPasswordController.self) == false
            }
        }
        
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(34 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(38)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(warningLabel)
        warningLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(26 * Constants.ScaleHeight)
            make.left.equalTo(descriptionLabel.snp.left)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(passphraseView)
        passphraseView.snp.makeConstraints { (make) in
            make.top.equalTo(warningLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(180)
        }
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(40 + Constants.BottomBarHeight))
            make.height.equalTo(Constants.BaseButtonHeight)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(remindButton)
        remindButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(continueButton.snp.top).offset(-20)
            make.width.equalTo(94)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
        }
        
        view.insertSubview(lineView, belowSubview: remindButton)
        lineView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(remindButton.snp.bottom).offset(-2)
            make.width.equalTo(94)
            make.height.equalTo(0.5)
        }
        
        continueButton.addTarget(self, action: #selector(self.backup), for: .touchUpInside)
        remindButton.addTarget(self, action: #selector(self.skip), for: .touchUpInside)
        
        if option == .read {
            remindButton.isHidden = true
            lineView.isHidden = true
            continueButton.snp.remakeConstraints { (make) in
                make.top.equalTo(passphraseView.snp.bottom).offset(50)
                make.height.equalTo(Constants.BaseButtonHeight)
                make.left.equalToSuperview().offset(30)
                make.centerX.equalToSuperview()
            }
        }
    }
    
    deinit {
        delegate?.didCancel(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PassphraseViewController {
    
    @objc func backup() {
        delegate?.didPressedContinueButton(account: account, words: words, in: self)
    }
    
    @objc func skip() {
        delegate?.didSkipToBackupPhrase(account: account, in: self)
    }
}

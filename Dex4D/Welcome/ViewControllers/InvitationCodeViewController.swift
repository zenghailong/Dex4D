//
//  InvitationCodeViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/31.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol InvitationCodeViewControllerDelegate: class {
    func didEnterInvitationCode()
}

class InvitationCodeViewController: BaseViewController {
    
    weak var delegate: InvitationCodeViewControllerDelegate?
    
    let viewModel = InvitationCodeViewModel()
    
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
        descLabel.textAlignment = .center
        return descLabel
    }()
    
    private lazy var textFieldView: CustomTextFieldView = {
        let view = CustomTextFieldView()
        view.backgroundColor = Colors.inputBackground
        view.textField.textColor = .white
        view.textField.font = UIFont.defaultFont(size: 14)
        view.textField.textAlignment = .center
        return view
    }()
    
    private lazy var scanButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.icon_scan(), for: .normal)
        button.addTarget(self, action: #selector(self.scanAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var continueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(viewModel.continueBtnText, for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = Colors.globalColor
        button.titleLabel?.font = viewModel.continueBtnTextFont
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.addTarget(self, action: #selector(self.buttonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.setCustomNavigationbar()
        
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.equalToSuperview().offset(44)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(38)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            make.height.equalTo(53)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        textFieldView.addSubview(scanButton)
        scanButton.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        textFieldView.textField.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(-40)
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
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        textFieldView.textField.resignFirstResponder()
    }
    
    @objc private func buttonAction() {
        guard var text = textFieldView.text, text != "" else {
            showTipsMessage(message: String(format: "%@ can't be empty".localized, "Invitation code".localized))
            return
        }
        if text.hasPrefix(Dex4DUrls.exchange) {
            text = text.replaceBy(pattern: Dex4DUrls.exchange, with: "")
        }
        displayLoading()
        if text.isEthereumAddress() {
            Dex4DProvider.shared.hasDex4DReferralAuthority(address: text) { [weak self] result in

                switch result {
                case .success(let flag):
                    if flag == 1 {
                        self?.saveCode(code: text)
                        self?.hideLoading()
                    } else {
                        Dex4DProvider.shared.getDex4DBalance(address: text) { [weak self] result in
                            self?.hideLoading()
                            switch result {
                            case .success(let data):
                                if let d4d = data["d4d"] as? [String: Any] {
                                    if let total = d4d["total"] as? Double {
                                        if total > AuthorityOperation(operation: .referral).dex4DCount {
                                            self?.saveCode(code: text)
                                            return
                                        }
                                    }
                                }
                                self?.showTipsMessage(message: "Invalid Invitation code".localized)
                            case .failure(_):
                                self?.hideLoading()
                            }
                        }
                    }
                case .failure(_):
                    self?.hideLoading()
                }
            }
            
        } else {
            Dex4DProvider.shared.getDex4DReferralAddress(username: text) { [weak self] result in

                self?.hideLoading()
                switch result {
                case .success(let address):
                    if address == EthereumAddress.zero.description {
                        self?.showTipsMessage(message: "Invalid Invitation code".localized)
                    } else {
                        self?.saveCode(code: text)
                    }
                case .failure(_):
                    break
                }
            }
        }
        
    }
    
    private func saveCode(code: String) {
        UserDefaults.setStringValue(value: code, key: Dex4DKeys.invitationCode)
        self.delegate?.didEnterInvitationCode()
    }
    
    @objc private func scanAction() {
        let vc = ScanViewController()
        vc.delegate = self
        pushToScan(navigationController: navigationController, push: vc)
    }
    
}

extension InvitationCodeViewController: ScanViewControllerDelegate {
    func didScanQRCode(result: String) {
        navigationController?.popViewController(animated: true)
        textFieldView.textField.text = result
    }
}

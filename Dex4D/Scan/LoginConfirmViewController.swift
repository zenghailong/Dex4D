//
//  LoginConfirmViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/13.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class LoginConfirmViewController: BaseViewController {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.scan_login()
        return imageView
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Upload your address to login".localized
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    private lazy var titleLabel2: UILabel = {
        let label = UILabel()
        label.text = "Web login".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 18)
        label.textAlignment = .center
        return label
    }()
    private lazy var titleLabel3: UILabel = {
        let label = UILabel()
        label.text = "Waiting".localized
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    
    private lazy var addressTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Address".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var addressValueLabel: UILabel = {
        let label = UILabel()
        label.text = address.addressShortString()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    private lazy var timeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Scanning time".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var timeValueLabel: UILabel = {
        let label = UILabel()
        label.text = Date.currentTime()
        label.textColor = Colors.textTips
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
    
    let qrString: String
    let address: String
    let viewController: UIViewController
    
    init(qrString: String, address: String, viewController: UIViewController) {
        self.qrString = qrString
        self.address = address
        self.viewController = viewController
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func backButtonAction() {
        dismissWith(confirm: false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 40 * Constants.ScaleHeight)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        view.addSubview(titleLabel2)
        titleLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        view.addSubview(titleLabel3)
        titleLabel3.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel2.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: "383847")
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel3.snp.bottom).offset(30 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
        
        view.addSubview(addressTitleLabel)
        addressTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
        }
        view.addSubview(addressValueLabel)
        addressValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(addressTitleLabel)
            make.left.equalTo(addressTitleLabel.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        view.addSubview(timeTitleLabel)
        timeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(addressTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
        }
        view.addSubview(timeValueLabel)
        timeValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeTitleLabel)
            make.left.equalTo(timeTitleLabel.snp.right).offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        
        view.addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(timeTitleLabel.snp.bottom).offset(100)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(49)
        }
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints { (make) in
            make.top.equalTo(submitButton.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(49)
        }
    }
    
    private func dismissWith(confirm: Bool) {
        let confirmStr = confirm ? "true" : "false"
        ScanProvider.shared.qrLoginConfirm(
            appname: qrString.qrStringAppName(),
            nonce: qrString.qrStringNonce(),
            address: address,
            confirm: confirmStr
        ) { [weak self] (result) in
            switch result {
            case .success(let status):
                if confirm {
                    if status {
//                        let vc = LoginSuccessViewController()
//                        self?.viewController.present(vc, animated: false, completion: nil)
                        self?.viewController.showTipsMessage(message: "Login success".localized)
                    } else {
                        self?.viewController.showTipsMessage(message: "Login failed".localized)
                    }
                }
            case .failure(_):
                break
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func submitButtonAction() {
        dismissWith(confirm: true)
    }
    
    @objc private func cancelButtonAction() {
        dismissWith(confirm: false)
    }

}

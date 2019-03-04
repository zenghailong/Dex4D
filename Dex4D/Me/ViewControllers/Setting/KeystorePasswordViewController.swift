//
//  KeystorePasswordViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/26.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol KeystorePasswordViewControllerDelegate: class {
    func pushToKeystore(password: String)
}

class KeystorePasswordViewController: BaseViewController {
    
    weak var delegate: KeystorePasswordViewControllerDelegate?
    
    private lazy var passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Input password".localized
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var textFieldView: CustomTextFieldView = {
        let view = CustomTextFieldView()
        view.backgroundColor = Colors.cellBackground
        view.textField.textColor = .white
        view.textField.font = UIFont.defaultFont(size: 14)
        view.textField.isSecureTextEntry = true
        return view
    }()
    
    private lazy var confirmPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Confirm password".localized
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var confirmTextFieldView: CustomTextFieldView = {
        let view = CustomTextFieldView()
        view.backgroundColor = Colors.cellBackground
        view.textField.textColor = .white
        view.textField.font = UIFont.defaultFont(size: 14)
        view.textField.isSecureTextEntry = true
        return view
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.setTitle("Confirm".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 21
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "Backup Keystore".localized
        
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: GenerateEnterPasswordController.self) == false
            }
        }
        
        view.addSubview(passwordLabel)
        passwordLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 5)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        view.addSubview(textFieldView)
        textFieldView.snp.makeConstraints { (make) in
            make.top.equalTo(passwordLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(49)
        }
        
        view.addSubview(confirmPasswordLabel)
        confirmPasswordLabel.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldView.snp.bottom).offset(35)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        view.addSubview(confirmTextFieldView)
        confirmTextFieldView.snp.makeConstraints { (make) in
            make.top.equalTo(confirmPasswordLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(49)
        }
        
        view.addSubview(confirmButton)
        confirmButton.snp.makeConstraints { (make) in
            make.top.equalTo(confirmTextFieldView.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(42)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textFieldView.textField.becomeFirstResponder()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        textFieldView.textField.resignFirstResponder()
        confirmTextFieldView.textField.resignFirstResponder()
    }
    
    @objc private func confirmButtonAction() {
        if textFieldView.text != confirmTextFieldView.text {
            showTipsMessage(message: "密码不一致")
            return
        }
        if textFieldView.text?.count == 0 {
            showTipsMessage(message: "密码不能为空")
            return
        }
        delegate?.pushToKeystore(password: textFieldView.text!)
    }

}



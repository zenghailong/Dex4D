//
//  GenerateEnterPasswordController.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/27.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol GenerateEnterPasswordControllerDelegate: class {
    func didFinishedCreatePin(in viewController: GenerateEnterPasswordController)
    func didCancelCreatePin(in viewController: GenerateEnterPasswordController)
    func didVerifyPassword(type: GeneratePasswordType)
}

class GenerateEnterPasswordController: BaseViewController {
    
    weak var delegate: GenerateEnterPasswordControllerDelegate?
    
    let type: GeneratePasswordType
    
    let coordinator: CreatePINCoordinator
    
    let pinCode: String
    
    private lazy var viewModel: GeneratePasswordViewModel = {
        return GeneratePasswordViewModel(type: type)
    }()
    
    private lazy var inputPinView: InputPinView = {
        let pinView = InputPinView(frame: CGRect(x: 0, y: 0, width: viewModel.pinViewSize, height: viewModel.circleSize), viewModel: viewModel)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showKeyBoard))
        pinView.addGestureRecognizer(tap)
        return pinView
    }()
    
    private lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = .numberPad
        textField.borderStyle = .roundedRect
        textField.isHidden = true
        textField.delegate = self
        textField.addTarget(self, action: #selector(valueChangedAction), for: .editingChanged)
        return textField
    }()
    
    private lazy var titleTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.font = UIFont.systemFont(ofSize: 22)
        return textLabel
    }()
    
    init(
        type: GeneratePasswordType,
         coordinator: CreatePINCoordinator,
         pin: String = ""
    ) {
        self.type = type
        self.pinCode = pin
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
       // super.setCustomNavigationbar()
        super.viewDidLoad()
        titleTextLabel.text = viewModel.description
        setCustomNavigationbar()
        if type != .verify {
            setBackButton()
        }
        
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { (make) in
            make.centerX.centerY.equalToSuperview()
        }
        
        view.addSubview(inputPinView)
        inputPinView.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(35)
            make.centerX.equalToSuperview()
            make.width.equalTo(viewModel.pinViewSize)
            make.height.equalTo(viewModel.circleSize)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        passwordTextField.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        passwordTextField.text = ""
        inputPinView.deleteAll()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
//        passwordTextField.resignFirstResponder()
    }
    
    @objc func showKeyBoard() {
        passwordTextField.becomeFirstResponder()
    }

    @objc fileprivate func nextAction() {
        if type == .confirm {
            guard pinCode == passwordTextField.text else {
                showTipsMessage(message: viewModel.errorText)
                return
            }
            KeyChainManager.shared.setPin(value: pinCode)
            delegate?.didFinishedCreatePin(in: self)
        } else if type == .input {
            let vc = GenerateEnterPasswordController(
                type: .confirm,
                coordinator: coordinator,
                pin: passwordTextField.text!.substring(to: viewModel.circleCount)
            )
            vc.delegate = coordinator
            navigationController?.pushViewController(vc, animated: true)
        } else {
            if KeyChainManager.shared.hasPin && KeyChainManager.shared.getPin() == passwordTextField.text {
                delegate?.didVerifyPassword(type: type)
            } else {
                showTipsMessage(message: viewModel.errorText)
            }
        }
    }
    
    @objc func valueChangedAction() {
        if passwordTextField.text?.count == viewModel.circleCount {
            nextAction()
        }
    }
    
    deinit {
        if type == .input {
           delegate?.didCancelCreatePin(in: self)
        }
    }
}

extension GenerateEnterPasswordController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "" {
            inputPinView.deleteNumber()
            return true
        }
        if string.isPasswordString() && textField.text!.count + string.count <= viewModel.circleCount {
            inputPinView.inputNumber()
            return true
        }
        if !string.isPasswordString() {
            showTipsMessage(message: "Please input number".localized)
        }
        return false
    }
    
}

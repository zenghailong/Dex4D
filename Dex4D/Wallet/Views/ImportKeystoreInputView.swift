//
//  ImportKeystoreInputView.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class InputKeystoreView: UIView {
    
    var textDidChangedBlock: ((UITextView) -> Void)?
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont.defaultFont(size: 16)
        textView.backgroundColor = .clear
        textView.delegate = self
        return textView
    }()
    
    lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        label.text = "Keystore".localized
        label.alpha = 0.3
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: "383848")
        
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(5)
            make.centerX.centerY.equalToSuperview()
        }
        
        addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { (make) in
            make.left.equalTo(textView.snp.left).offset(6)
            make.top.equalTo(textView.snp.top).offset(8)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.textViewChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    @objc func textViewChanged() {
        placeHolderLabel.isHidden = textView.text.isEmpty ? false : true
        textDidChangedBlock?(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputKeystoreView: UITextViewDelegate {
   private func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"{
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

class InputkeystorePasswordView: UIView {
    
    var textDidChangedBlock: ((UITextField) -> Void)?
    
    lazy var textField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.font = UIFont.defaultFont(size: 20)
        textField.isSecureTextEntry = true
        let placeholserAttributes = [NSAttributedStringKey.foregroundColor : Colors.textAlpha, NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14)]
        textField.attributedPlaceholder = NSAttributedString(string: "Input password".localized, attributes: placeholserAttributes)
        textField.delegate = self
        return textField
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: "383848")
        
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(25)
            make.top.bottom.centerX.equalToSuperview()
        }
        textField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        textDidChangedBlock?(textField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputkeystorePasswordView: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


//
//  CustomTextField.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/26.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class CustomTextFieldView: UIView {
    
    var text: String? {
        get {
            return textField.text
        }
        set {
            textField.text = text
        }
    }
    
    var textField: UITextField = {
        let textField = UITextField()
        textField.text = ""
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setValue(Colors.textTips, forKeyPath: "_placeholderLabel.textColor")
        return textField
    }()
    
    init() {
        super.init(frame: CGRect())
        layer.cornerRadius = 6
        layer.masksToBounds = true
        addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

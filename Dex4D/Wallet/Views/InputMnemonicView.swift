//
//  InputMnemonicView.swift
//  Dex4D
//
//  Created by zeng hai long on 22/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class InputMnemonicView: UIView {

    var textDidChangedBlock: ((UITextView) -> Void)?
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont.defaultFont(size: 16)
        textView.backgroundColor = .clear
        return textView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        backgroundColor = UIColor(hex: "383848")
        
        addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(10)
            make.centerX.centerY.equalToSuperview()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.textViewChanged), name: NSNotification.Name.UITextViewTextDidChange, object: nil)
    }
    
    @objc func textViewChanged() {
        textDidChangedBlock?(textView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  LoginSuccessViewController.swift
//  Dex4D
//
//  Created by lax on 2018/11/21.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class LoginSuccessViewController: BaseViewController {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.scan_login()
        return imageView
    }()
    
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "You have signed onto web Dex4D".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 18)
        label.textAlignment = .center
        return label
    }()
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.attributedText = "Login in Web with your app only sendyour address. \nYou can sign transaction with private key on your mobile safely".localized.toAttributedString()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        _ = navigationBar.setRightButtonTitle(title: "Done".localized, target: self, action: #selector(self.dismissButtonAction))
        
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.bottom.equalTo(view.snp.centerY).offset(-30)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(52)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
        }
        view.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(9)
            make.left.equalToSuperview().offset(34)
            make.right.equalToSuperview().offset(-34)
        }
    }
    
    @objc private func dismissButtonAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
}


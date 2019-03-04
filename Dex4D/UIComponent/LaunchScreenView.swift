//
//  LaunchScreenView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/30.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class LaunchScreenView: UIView {
    
    private lazy var logoImageView: UIImageView = {
        return UIImageView.init(image: R.image.welcome_logo())
    }()
    
    private lazy var textImageView: UIImageView = {
        return UIImageView.init(image: R.image.logo_text())
    }()
    
    private lazy var bottomLabel: UILabel = {
        let label = UILabel()
        label.text = "Welcome to Dex4D New Dimensions"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    init() {
        super.init(frame: UIScreen.main.bounds)
        backgroundColor = Colors.background
        
        addSubview(logoImageView)
        logoImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalTo(self.snp.top).offset(Constants.ScreenHeight / 4)
        }
        addSubview(textImageView)
        textImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(24)
        }
        addSubview(bottomLabel)
        bottomLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-40)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

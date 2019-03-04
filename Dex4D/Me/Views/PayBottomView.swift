//
//  PayBottomView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/15.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class PayBottomView: UIView {
    
    lazy var bottomTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    lazy var txHashLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 2
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    
    init() {
        super.init(frame: CGRect())
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.backgroundColor = Colors.cellBackground
        
        self.addSubview(bottomTitleLabel)
        bottomTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.top.equalTo(bottomTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(txHashLabel)
        txHashLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipsLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hideTitleLabel() {
        bottomTitleLabel.isHidden = true
    }
    
    func showTitleLabel() {
        bottomTitleLabel.isHidden = false
    }
    
}

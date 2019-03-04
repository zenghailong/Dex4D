//
//  HomeSectionHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class HomeSectionHeaderView: UIView {

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Coin".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.text = "Price".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.text = "24h Change".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: 28))
        self.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(22)
        }
        
        self.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(countLabel)
        countLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-22)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

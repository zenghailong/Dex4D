//
//  TransactionsMenuViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class TransactionsMenuViewCell: UICollectionViewCell {
    
    var isCurrent = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 5
        label.layer.masksToBounds = true
        label.backgroundColor = .clear
        label.textColor = Colors.textTips
        label.textAlignment = .center
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setText(text: String) {
        titleLabel.text = text
    }
    
    func setStatusNormal() {
        isCurrent = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = Colors.textTips
    }
    
    func setStatusSeleted() {
        isCurrent = true
        titleLabel.backgroundColor = Colors.globalColor
        titleLabel.textColor = .white
    }

}

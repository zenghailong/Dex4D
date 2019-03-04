//
//  HistoryTableViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class HistoryTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.cellBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.text = "ETH"
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.globalColor
        label.text = "(等待)"
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var numberLabel: UILabel = {
        let label = UILabel()
        label.text = "-0.0000001"
        label.textAlignment = .right
        label.textColor = UIColor(hex: "DC4D4D")
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "2018-08-08 08:08:08"
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "balance: "
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var balanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = "2.34099"
        label.textColor = .white
        label.textAlignment = .right
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
        }
        
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(10)
            make.centerY.equalTo(nameLabel)
        }
        
        containerView.addSubview(numberLabel)
        numberLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
        }
        
        containerView.addSubview(balanceValueLabel)
        balanceValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(balanceTitleLabel)
        balanceTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalTo(balanceValueLabel.snp.left)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


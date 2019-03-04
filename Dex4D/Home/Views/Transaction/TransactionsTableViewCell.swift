//
//  TransactionsTableViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class TransactionsTableViewCell: UITableViewCell {

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
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var typeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.globalColor
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var hashLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
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
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(10)
        }
        
        containerView.addSubview(typeLabel)
        typeLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.left.equalTo(nameLabel.snp.right).offset(15)
        }
        
        containerView.addSubview(statusLabel)
        statusLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameLabel)
            make.right.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(timeLabel)
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
        }
        
        containerView.addSubview(hashLabel)
        hashLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(timeLabel)
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configCell(wtih transaction: DexTransaction) {
        nameLabel.text = transaction.assetPairs
        typeLabel.text = "(\(transaction.type.convertFirstLetterToUppercase().localized))"
        statusLabel.text = transaction.status == "Pending" ? "Transaction.pending".localized : transaction.status.localized
        timeLabel.text = transaction.formatterTime
        hashLabel.text = transaction.txHashValue
    }
    
    
}

extension String {
   func convertFirstLetterToUppercase() -> String {
        let firstStr = self.substring(to: 1)
        let backStr = self.substring(from: 1)
        return firstStr.uppercased() + backStr
    }
}

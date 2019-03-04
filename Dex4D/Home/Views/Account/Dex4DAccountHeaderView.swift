//
//  Dex4DAccountHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol Dex4DAccountHeaderViewDelegate: class {
    func didSelectWithdrawButton()
    func didSelectTransactionsButton()
}

class Dex4DAccountHeaderView: UIView {
    
    weak var delegate: Dex4DAccountHeaderViewDelegate?
    
    private lazy var balanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total Token balance".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var balanceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 20)
        label.textAlignment = .right
        label.text = "0.00"
        return label
    }()
    
    private lazy var dex4dTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Total D4D balance".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var dex4dValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 20)
        label.textAlignment = .right
        label.text = "0"
        return label
    }()
    
    private lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.titleLabel?.font = UIFont.defaultFont(size: 12)
        button.setTitle("Withdraw".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.setImage(R.image.icon_withdraw(), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.withdrawButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var transactionsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.titleLabel?.font = UIFont.defaultFont(size: 12)
        button.setTitle("Transaction".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        button.setImage(R.image.icon_transaction(), for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.transactionsButtonAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 184))
        initSubViews()
    }
    
    func configHeaderView(with viewModel: DexAccountViewModel) {
        if let revenue = viewModel.revenue, let totalRevenue = revenue["total"] as? Double {
            balanceValueLabel.text = viewModel.config.currencySymbol + totalRevenue.stringFloor2Value()
        }
        if let d4d = viewModel.d4d, let totalCount = d4d["total"] as? Double {
            dex4dValueLabel.text = totalCount == 0 ? "0": totalCount.stringFloor6Value()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews() {
        self.addSubview(balanceTitleLabel)
        balanceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.right.equalTo(self.snp.centerX).offset(-20)
            make.top.equalToSuperview().offset(20)
        }
        
        self.addSubview(balanceValueLabel)
        balanceValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.snp.centerX)
            make.right.equalToSuperview().offset(-30)
            make.centerY.equalTo(balanceTitleLabel)
        }
        
        self.addSubview(dex4dTitleLabel)
        dex4dTitleLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(balanceTitleLabel)
            make.top.equalTo(balanceTitleLabel.snp.bottom).offset(24)
        }
        
        self.addSubview(dex4dValueLabel)
        dex4dValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(dex4dTitleLabel.snp.right)
            make.right.equalTo(balanceValueLabel)
            make.centerY.equalTo(dex4dTitleLabel)
        }
        
        self.addSubview(withdrawButton)
        withdrawButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(dex4dValueLabel.snp.bottom).offset(40)
            make.height.equalTo(40)
            make.width.equalTo((Constants.ScreenWidth - 50) / 2)
        }
        
        self.addSubview(transactionsButton)
        transactionsButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.top.width.height.equalTo(withdrawButton)
        }
    }
    
    @objc private func withdrawButtonAction() {
        self.delegate?.didSelectWithdrawButton()
    }
    
    @objc private func transactionsButtonAction() {
        self.delegate?.didSelectTransactionsButton()
    }
    
}

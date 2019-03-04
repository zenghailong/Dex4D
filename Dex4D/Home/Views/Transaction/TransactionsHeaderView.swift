//
//  TransactionsHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit


protocol TransactionsHeaderViewDelegate: class {
    func filterTransactions(with selectedType: Dex4DTransactionsType, selectedStatus: DexTransactionsStatus)
}

class TransactionsHeaderView: UIView {

    weak var delegate: TransactionsHeaderViewDelegate?
    
    private lazy var filterTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Type".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private let filterMenuView = TransactionsMenuView(
        typeArray: [.all, .buy, .reinvest, .sell, .swap, .withdraw],
        statusArray: [],
        menuType: .type
    )
    
    private lazy var coinTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Status".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private let coinMenuView = TransactionsMenuView(
        typeArray: [],
        statusArray: [.all, .pending, .success, .failed],
        menuType: .status
    )
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 160))
        initSubViews()
        filterMenuView.menuDelegate = self
        coinMenuView.menuDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initSubViews() {
        
        self.addSubview(filterTitleLabel)
        filterTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalToSuperview().offset(10)
        }
        
        self.addSubview(filterMenuView)
        filterMenuView.snp.makeConstraints { (make) in
            make.top.equalTo(filterTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(25)
        }
    
        
        self.addSubview(coinTitleLabel)
        coinTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.top.equalTo(filterMenuView.snp.bottom).offset(20)
        }
        
        self.addSubview(coinMenuView)
        coinMenuView.snp.makeConstraints { (make) in
            make.top.equalTo(coinTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(25)
        }
        
    }

}

extension TransactionsHeaderView: TransactionsMenuViewDelegate {
    func didSelectedFilterButton() {
        delegate?.filterTransactions(with: filterMenuView.selectedType, selectedStatus: coinMenuView.selectedStatus)
    }
}

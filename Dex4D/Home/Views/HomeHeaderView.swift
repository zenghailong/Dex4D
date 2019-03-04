//
//  HomeHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import RealmSwift

protocol HomeHeaderViewDelegate: class {
    func didSelectContainerView()
}

class HomeHeaderView: UIView {
    
    weak var delegate: HomeHeaderViewDelegate?
    
    let config: DexConfig
    let transactionStore: DexTransactionsStorage
    
    lazy var viewModel: HomeHeaderViewModel = {
        return HomeHeaderViewModel(config: config, transactionStore: transactionStore)
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    
    
    private lazy var capitalTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.capitalTitleLabelText
        label.font = viewModel.capitalTitleLabelFont
        label.textColor = viewModel.capitalTitleLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var hideAssetButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(R.image.icon_eye_open_home(), for: .normal)
        button.addTarget(self, action: #selector(self.hideAssetButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var capitalValueLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.capitalValueLabelText
        label.font = viewModel.capitalValueLabelFont
        label.textColor = viewModel.capitalValueLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.font = viewModel.pendingLabelFont
        label.textColor = viewModel.pendingLabelColor
        label.textAlignment = .center
        return label
    }()
    
    
    
    private lazy var tokenBalanceTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.tokenBalanceTitleLabelText
        label.font = viewModel.tokenBalanceTitleLabelFont
        label.textColor = viewModel.tokenBalanceTitleLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var tokenBalanceValueLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.tokenBalanceValueLabelText
        label.font = viewModel.tokenBalanceValueLabelFont
        label.textColor = viewModel.tokenBalanceValueLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dex4dTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.dex4dTitleLabelText
        label.font = viewModel.dex4dTitleLabelFont
        label.textColor = viewModel.dex4dTitleLabelColor
        label.textAlignment = .center
        return label
    }()
    
    private lazy var dex4dValueLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.dex4dValueLabelText
        label.font = viewModel.dex4dValueLabelFont
        label.textColor = viewModel.dex4dValueLabelColor
        label.textAlignment = .center
        return label
    }()
    
    var isHideAsset: Bool {
        get {
            return UserDefaults.getBoolValue(for: Dex4DKeys.isHideHomeAsset)
        }
        set {
            UserDefaults.setBoolValue(value: newValue, key: Dex4DKeys.isHideHomeAsset)
        }
    }
    
    init(frame: CGRect, config: DexConfig, transactionStore: DexTransactionsStorage) {
        self.config = config
        self.transactionStore = transactionStore
        super.init(frame: frame)
        initSubViews()
        
        setTotalAsset()
        setPeddingLabelText()
    }
    
    func refreshHeaderView(_ viewModel: DexAccountViewModel) {
        if let revenue = viewModel.revenue, let totalRevenue = revenue["total"] as? Double {
            self.viewModel.tokenBalanceValueLabelText = totalRevenue.stringFloor2Value()
            var totalCapital = totalRevenue
            if let d4d = viewModel.d4d, let totalPrice = d4d["totalPrice"] as? Double {
                totalCapital += totalPrice
            }
            self.viewModel.capitalValueLabelText = totalCapital.stringFloor2Value()
        }
        if let d4d = viewModel.d4d, let totalCount = d4d["total"] as? Double {
            self.viewModel.dex4dValueLabelText = totalCount == 0 ? "0": totalCount.stringFloor6Value()
        }
        setTotalAsset()
    }
    
    private func setTotalAsset() {
        if isHideAsset {
            hideAssetButton.setImage(R.image.icon_eye_close_home(), for: .normal)
            capitalValueLabel.text = Dex4DKeys.hideAssetSymbol
            tokenBalanceValueLabel.text = Dex4DKeys.hideAssetSymbol
            dex4dValueLabel.text = Dex4DKeys.hideAssetSymbol
        } else {
            hideAssetButton.setImage(R.image.icon_eye_open_home(), for: .normal)
            capitalValueLabel.text = config.currencySymbol + viewModel.capitalValueLabelText
            tokenBalanceValueLabel.text = config.currencySymbol + viewModel.tokenBalanceValueLabelText
            dex4dValueLabel.text = viewModel.dex4dValueLabelText
        }
    }
    
    @objc private func hideAssetButtonAction(sender: UIButton) {
        isHideAsset = !isHideAsset
        setTotalAsset()
    }
    
    @objc private func tapAction() {
        delegate?.didSelectContainerView()
    }
    
    func setPeddingLabelText() {
        if transactionStore.pendingObjects.count > 0 {
            pendingLabel.isHidden = false
            pendingLabel.text = String(transactionStore.pendingObjects.count) + "Transaction Pending".localized
        } else {
            pendingLabel.isHidden = true
            pendingLabel.text = nil
        }
    }
    
    
    private func initSubViews() {
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.top.equalToSuperview().offset(10)
        }
        
        let backgroundImage = UIImageView(image: R.image.dex4d_account_bg())
        backgroundImage.contentMode = .scaleAspectFill
        containerView.insertSubview(backgroundImage, at: 0)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = viewModel.backgroundViewColor
        containerView.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(56 * Constants.ScaleWidth)
        }
        
        containerView.addSubview(capitalTitleLabel)
        capitalTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24 * Constants.ScaleWidth)
            make.centerX.equalToSuperview().offset(-15)
        }
        
        containerView.addSubview(hideAssetButton)
        hideAssetButton.snp.makeConstraints { (make) in
            make.left.equalTo(capitalTitleLabel.snp.right).offset(5)
            make.centerY.equalTo(capitalTitleLabel)
            make.width.equalTo(38)
            make.height.equalTo(30)
        }
        
        containerView.addSubview(capitalValueLabel)
        capitalValueLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(45 * Constants.ScaleWidth)
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalTo(capitalValueLabel.snp.bottom)
        }
        
        containerView.addSubview(tokenBalanceTitleLabel)
        tokenBalanceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(containerView.snp.centerX).offset(-20)
            make.bottom.equalToSuperview().offset(-34 * Constants.ScaleWidth)
        }
        
        containerView.addSubview(tokenBalanceValueLabel)
        tokenBalanceValueLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(containerView.snp.centerX).offset(-20)
            make.bottom.equalToSuperview().offset(-10 * Constants.ScaleWidth)
        }
        
        containerView.addSubview(dex4dTitleLabel)
        dex4dTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.centerX).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalTo(tokenBalanceTitleLabel)
        }
        
        containerView.addSubview(dex4dValueLabel)
        dex4dValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.centerX).offset(20)
            make.right.equalToSuperview().offset(-20)
            make.top.centerY.equalTo(tokenBalanceValueLabel)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

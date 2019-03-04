//
//  TradeHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Kingfisher

class TradeHeaderView: UIView {

    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
        return view
    }()
    
    private lazy var coinImageView: UIImageView = {
        let imageView = UIImageView()
        if let dexTokenObject = dexToken {
            imageView.kf.setImage(
                with: URL(string: dexTokenObject.icon_app),
                placeholder: R.image.token_placeHolder(),
                options: nil, progressBlock: nil,
                completionHandler: nil
            )
        }
        return imageView
    }()
    
    private lazy var coinNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 24)
        return label
    }()
    
    private lazy var tokenBalanceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var tokenBalanceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        return label
    }()
    
    private lazy var d4dBalanceTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var d4dBalanceValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        return label
    }()
    
    let pool: DexPool
    let dexTokenStorage: DexTokenStorage
    let accountViewModel: DexAccountViewModel
    var dexToken: DexTokenObject?
    var viewModel: TradeHeaderViewModel?
    var newTokenPool: DexPool? {
        didSet {
           refresh(pool: newTokenPool ?? pool)
        }
    }
    init(
        pool: DexPool,
        dexTokenStorage: DexTokenStorage,
        accountViewModel: DexAccountViewModel
    ) {
        self.pool = pool
        self.dexTokenStorage = dexTokenStorage
        self.accountViewModel = accountViewModel
        self.dexToken = accountViewModel.tokenObjects.filter { $0.name == pool.tokenName }.first
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 110 * Constants.ScaleWidth + 20))
        self.initSubViews()
        self.refresh(pool: pool)
    }
    
    private func refresh(pool: DexPool) {
        self.viewModel = TradeHeaderViewModel(pool: pool, dexTokenStorage: dexTokenStorage)

        self.tokenBalanceValueLabel.text = pool.revenue == 0 ? "0" : pool.revenue?.stringFloor6Value()
        self.d4dBalanceValueLabel.text = pool.d4dCount == 0 ? "0" : pool.d4dCount?.stringFloor6Value()
//        self.viewModel?.getPoolMarketCapCompleted = {[weak self] poolMarketInfo in
//            guard let `self` = self else { return }
//            self.volumeValueLabel.text = poolMarketInfo.overall_volume == 0 ? "0" : poolMarketInfo.overall_volume.stringFloor6Value()
//            self.dividendsValueLabel.text = poolMarketInfo.dividends == 0 ? "0" : poolMarketInfo.dividends.stringFloor6Value()
//        self.viewModel?.getPoolMarketCapCompleted = {[weak self] poolMarketInfo in
//            guard let `self` = self else { return }
//            self.tokenBalanceValueLabel.text = poolMarketInfo.overall_volume == 0 ? "0" : poolMarketInfo.overall_volume.stringFloor6Value()
//            self.d4dBalanceValueLabel.text = poolMarketInfo.dividends == 0 ? "0" : poolMarketInfo.dividends.stringFloor6Value()
//        }
        coinNameLabel.text = viewModel?.tokenSymbol.uppercased()
        tokenBalanceTitleLabel.text = viewModel?.totalVolumText
        d4dBalanceTitleLabel.text = viewModel?.totalDividendsText
    }

    
    private func initSubViews() {
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalToSuperview().offset(-20)
        }
        
        let backgroundImage = UIImageView(image: R.image.dex4d_account_bg())
        backgroundImage.contentMode = .scaleAspectFill
        containerView.insertSubview(backgroundImage, at: 0)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        containerView.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.top.equalToSuperview().offset(14 * Constants.ScaleWidth)
            make.width.height.equalTo(22)
        }
        
        containerView.addSubview(coinNameLabel)
        coinNameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinImageView.snp.right).offset(7)
            make.centerY.equalTo(coinImageView)
        }
        
        containerView.addSubview(tokenBalanceTitleLabel)
        tokenBalanceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.right.equalTo(containerView.snp.centerX).offset(-14)
            make.top.equalTo(coinImageView.snp.bottom).offset(23 * Constants.ScaleWidth)
        }
        
        containerView.addSubview(tokenBalanceValueLabel)
        tokenBalanceValueLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(14)
            make.right.equalTo(containerView.snp.centerX).offset(-14)
            make.top.equalTo(tokenBalanceTitleLabel.snp.bottom).offset(6)
        }
        
        containerView.addSubview(d4dBalanceTitleLabel)
        d4dBalanceTitleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.centerX).offset(14)
            make.right.equalToSuperview().offset(-14)
            make.centerY.equalTo(tokenBalanceTitleLabel)
        }
        
        containerView.addSubview(d4dBalanceValueLabel)
        d4dBalanceValueLabel.snp.makeConstraints { (make) in
            make.left.equalTo(containerView.snp.centerX).offset(14)
            make.right.equalToSuperview().offset(-14)
            make.top.centerY.equalTo(tokenBalanceValueLabel)
        }
        
    }
    
    @objc private func tapAction() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

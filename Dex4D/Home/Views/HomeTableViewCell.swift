//
//  HomeTableViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Kingfisher

class HomeTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.cellBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var coinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_eth()
        return imageView
    }()
    
    private lazy var coinNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var priceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var flatLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var markLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont(size: 10)
        label.layer.borderWidth = 1.0
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
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
        
        containerView.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(13)
            make.width.equalTo(22)
            make.height.equalTo(22)
        }
        
        containerView.addSubview(coinNameLabel)
        coinNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(coinImageView.snp.right).offset(13)
        }
        
        containerView.addSubview(markLabel)
        markLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinNameLabel.snp.right).offset(8)
            make.centerY.equalToSuperview()
            make.height.width.equalTo(20)
        }
        
        containerView.addSubview(priceLabel)
        priceLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        containerView.addSubview(flatLabel)
        flatLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-13)
        }
    }
    
    func configCell(With marketcap: DexMarketcap, token: DexTokenObject?) {

        coinNameLabel.text = marketcap.symbol.uppercased()
        priceLabel.text = String(format: "%.8f", marketcap.whitout_fee_price)
        coinImageView.kf.setImage(
            with: URL(string: token?.icon_app ?? ""),
            placeholder: R.image.token_placeHolder(),
            options: nil, progressBlock: nil,
            completionHandler: nil
        )
        let temp = (marketcap.whitout_fee_price / marketcap.pre_24hours_price) - 1
        let flat = Double(round(temp * 10000).intValue()) / 100
       
        if flat > 0 {
            priceLabel.textColor = Colors.textGreen
            flatLabel.textColor = Colors.textGreen
            flatLabel.text = "+" + String(format: "%.2f", flat) + "%"
        } else if flat < 0 {
            priceLabel.textColor = Colors.textRed
            flatLabel.textColor = Colors.textRed
            flatLabel.text = String(format: "%.2f", flat) + "%"
        } else {
            priceLabel.textColor = .white
            flatLabel.textColor = .white
            flatLabel.text = "0.00%"
        }
        if let token = token {
            markLabel.textColor = UIColor(hex: token.tokenState.colorString)
            markLabel.layer.borderColor = UIColor(hex: token.tokenState.colorString).cgColor
            markLabel.isHidden = token.tokenState == .regular ? true : false
            markLabel.text = token.tokenState.descripton.localized
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

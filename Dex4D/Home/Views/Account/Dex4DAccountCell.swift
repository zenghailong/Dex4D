//
//  Dex4DAccountCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Kingfisher

protocol Dex4DAccountCellDelegate: class {
    func didPressedTradeButton(model: DexPool)
}

class Dex4DAccountCell: UITableViewCell {
    
    weak var delegate: Dex4DAccountCellDelegate?
    weak var viewDelegate: Dex4DAccountCollectionViewDelegate?
    var model: DexPool?

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
    
    private lazy var markLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.defaultFont(size: 10)
        label.textColor = UIColor(hex: "00DF86")
        label.layer.borderColor = UIColor(hex: "00DF86").cgColor
        label.layer.borderWidth = 1.0
        label.textAlignment = .center
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        return label
    }()
    
    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()

    private lazy var tradeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont(size: 12)
        button.setTitle("Trade".localized, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.globalColor.cgColor
        button.addTarget(self, action: #selector(self.tradeAction), for: .touchUpInside)
        return button
    }()

    private lazy var dex4dTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "D4D asset".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()

    private lazy var dex4dValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = "0"
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()

    private lazy var tokenTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Realized token".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()

    private lazy var tokenValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = "0"
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()

    private lazy var txsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Txs dividends".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()

    private lazy var txsValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()

    private lazy var refTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Ref dividends".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()

    private lazy var refValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()

    private lazy var collectionView: Dex4DAccountCollectionView = {
        let view = Dex4DAccountCollectionView()
        view.viewDelegate = self.viewDelegate
        return view
    }()
    
    private lazy var line: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: "272733")
        return line
    }()
    
    private lazy var lineBottom: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: "272733")
        return line
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
            make.height.equalToSuperview().offset(-20)
        }

        containerView.addSubview(coinImageView)
        coinImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.equalTo(22)
            make.height.equalTo(22)
        }

        containerView.addSubview(coinNameLabel)
        coinNameLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinImageView)
            make.left.equalTo(coinImageView.snp.right).offset(10)
        }
        
        containerView.addSubview(markLabel)
        markLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinNameLabel.snp.right).offset(11)
            make.centerY.equalTo(coinNameLabel)
            make.height.width.equalTo(20)
        }
        
        containerView.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(markLabel)
            make.left.equalTo(markLabel.snp.right).offset(7)
        }

        containerView.addSubview(tradeButton)
        tradeButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinImageView)
            make.right.equalToSuperview().offset(-6)
            make.width.equalTo(55)
            make.height.equalTo(25)
        }

        containerView.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
            make.top.equalToSuperview().offset(40)
        }

        containerView.addSubview(dex4dTitleLabel)
        dex4dTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
        }

        containerView.addSubview(dex4dValueLabel)
        dex4dValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dex4dTitleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
        }

        containerView.addSubview(tokenTitleLabel)
        tokenTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(containerView.snp.centerX).offset(30)
        }

        containerView.addSubview(tokenValueLabel)
        tokenValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenTitleLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(containerView.snp.centerX).offset(30)
        }

        containerView.addSubview(txsTitleLabel)
        txsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dex4dValueLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
        }

        containerView.addSubview(txsValueLabel)
        txsValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(txsTitleLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(10)
            make.right.equalTo(containerView.snp.centerX).offset(-10)
        }

        containerView.addSubview(refTitleLabel)
        refTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tokenValueLabel.snp.bottom).offset(15)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(containerView.snp.centerX).offset(30)
        }

        containerView.addSubview(refValueLabel)
        refValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(refTitleLabel.snp.bottom).offset(5)
            make.right.equalToSuperview().offset(-10)
            make.left.equalTo(containerView.snp.centerX).offset(30)
        }

        
        containerView.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(txsValueLabel.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.height.equalTo(49)
        }
        
        containerView.addSubview(lineBottom)
        lineBottom.snp.makeConstraints { (make) in
            make.top.equalTo(collectionView)
            make.left.right.equalToSuperview()
            make.height.equalTo(1)
        }

    }
    
    func configAccountCell(with pool: DexPool, token: DexTokenObject?, transactions: Array<DexTransaction>) {
        self.model = pool
        coinNameLabel.text = pool.tokenName.uppercased()
        coinImageView.kf.setImage(
            with: URL(string: token?.icon_app ?? ""),
            placeholder: R.image.token_placeHolder(),
            options: nil, progressBlock: nil,
            completionHandler: nil
        )
        
        if let token = token {
            markLabel.textColor = UIColor(hex: token.tokenState.colorString)
            markLabel.layer.borderColor = UIColor(hex: token.tokenState.colorString).cgColor
            markLabel.isHidden = token.tokenState == .regular ? true : false
            markLabel.text = token.tokenState.descripton.localized
        }
        
        pendingLabel.text = transactions.count > 0 ? "( " + String(transactions.count) + "Transaction Pending".localized + " )" : nil
        
        if let dexBalance = pool.d4dCount {
            dex4dValueLabel.text = dexBalance == 0 ? "0" : dexBalance.stringFloor6Value()
        }
        if let coinBalance = pool.coin {
            tokenValueLabel.text = coinBalance == 0 ? "0" : coinBalance.stringFloor6Value()
        }
        if let dividends = pool.dividends {
            txsValueLabel.text = dividends == 0 ? "0" : dividends.stringFloor6Value()
        }
        if let rebateFees = pool.rebateFeelets {
            refValueLabel.text = rebateFees == 0 ? "0" : rebateFees.stringFloor6Value()
        }

        lineBottom.isHidden = pool.games.count > 0 ? false : true
        collectionView.isHidden = pool.games.count > 0 ? false : true
        collectionView.dataArray = pool.games
        collectionView.reloadData()
    }

    @objc private func tradeAction(sender: UIButton) {
        guard let model = model else {
            return
        }
        self.delegate?.didPressedTradeButton(model: model)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

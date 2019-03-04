//
//  PayETHView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol PayETHViewDelegate: class {
    func didSelectETHSubmitButton()
}

class PayETHView: UIView {

    weak var delegate: PayETHViewDelegate?
    
    let viewModel: AuthorityPayViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.payETHTitleLabelText
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.payETHBalanceLabelText
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 14)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.setTitle(viewModel.payETHSubmitButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.tradeButtonAction), for: .touchUpInside)
        return button
    }()
    
    
    init(viewModel: AuthorityPayViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 250))
        
        self.layer.cornerRadius = 6
        self.layer.masksToBounds = true
        self.backgroundColor = Colors.cellBackground
        
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
            make.height.equalTo(40)
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func tradeButtonAction() {
        delegate?.didSelectETHSubmitButton()
    }
    
    func checkSubmitButton() {
        if viewModel.ethBalance < viewModel.ethCount || viewModel.ethBalance == 0 {
            submitButton.isEnabled = false
            submitButton.backgroundColor = Colors.buttonInvalid
            submitButton.setTitleColor(Colors.buttonInvalidText, for: .normal)
        } else {
            submitButton.isEnabled = true
            submitButton.backgroundColor = Colors.globalColor
            submitButton.setTitleColor(.white, for: .normal)
        }
    }
    
    func ethBalanceValueChanged() {
        balanceLabel.text = viewModel.payETHBalanceLabelText
    }
    func ethCountValueChanged() {
        submitButton.setTitle(viewModel.payETHSubmitButtonText, for: .normal)
        titleLabel.text = viewModel.payETHTitleLabelText
    }
}

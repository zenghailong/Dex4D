//
//  PayDex4DView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol PayDex4DViewDelegate: class {
    func didSelectDex4DSubmitButton()
}

class PayDex4DView: UIView {
    
    weak var delegate: PayDex4DViewDelegate?
    
    let viewModel: AuthorityPayViewModel
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.payDex4DTitleLabelText
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        return label
    }()
    
    private lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.payDex4DBalanceLabelText
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 16)
        return label
    }()
    
    private lazy var progressView: CustomProgressView = {
        let view = CustomProgressView()
        view.backgroundColor = UIColor(hex: "50505D")
        view.frontColor = Colors.globalColor
        view.progress = viewModel.progress
        return view
    }()
    
    private lazy var minValueLabel: UILabel = {
        let label = UILabel()
        label.text = "0%"
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var currentValueLabel: UILabel = {
        let label = UILabel()
        label.text = "\(Int(viewModel.progress * 100))%"
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var maxValueLabel: UILabel = {
        let label = UILabel()
        label.text = "100%"
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.setTitle(viewModel.payDex4DSubmitButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.submitButtonAction), for: .touchUpInside)
        return button
    }()
    
    
    init(viewModel: AuthorityPayViewModel) {
        self.viewModel = viewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 160))
        
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
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(30)
            make.height.equalTo(6)
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-15)
        }
        
        self.addSubview(minValueLabel)
        minValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(progressView.snp.bottom).offset(10)
            make.left.equalTo(progressView)
        }
        
        self.addSubview(currentValueLabel)
        currentValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(maxValueLabel)
        maxValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.right.equalTo(progressView)
        }
        
        if viewModel.authorityOperation.operation == .referral {
            self.addSubview(submitButton)
            submitButton.snp.makeConstraints { (make) in
                make.top.equalTo(minValueLabel.snp.bottom).offset(50)
                make.left.equalToSuperview().offset(15)
                make.right.equalToSuperview().offset(-15)
                make.height.equalTo(42)
            }
            checkSubmitButton()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func submitButtonAction() {
        delegate?.didSelectDex4DSubmitButton()
    }
    
    func checkSubmitButton() {
        if viewModel.authorityOperation.authority == .forever ||
           viewModel.authorityOperation.authority == .temp {
            submitButton.isEnabled = true
            submitButton.backgroundColor = Colors.globalColor
            submitButton.setTitleColor(.white, for: .normal)
        } else {
            submitButton.isEnabled = false
            submitButton.backgroundColor = Colors.buttonInvalid
            submitButton.setTitleColor(Colors.buttonInvalidText, for: .normal)
        }
    }
    
    func dex4DBalanceValueChanged() {
        checkSubmitButton()
        balanceLabel.text = viewModel.payDex4DBalanceLabelText
        progressView.progress = viewModel.progress
        currentValueLabel.text = "\(Int(viewModel.progress * 100))%"
    }
    func authorityValueChanged() {
        checkSubmitButton()
        titleLabel.text = viewModel.payDex4DTitleLabelText
    }
}

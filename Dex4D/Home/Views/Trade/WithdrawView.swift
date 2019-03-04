//
//  WithdrawView.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/6.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol WithdrawViewDelegate: class {
    func didPressedWithdraw(for view: WithdrawView)
}
class WithdrawView: UIView {

    private lazy var tradeTitleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.tradeTitleText
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 16)
        return label
    }()
    
    private lazy var textFieldBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.inputBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var tradeTextField: UITextField = {
        let textField = UITextField()
        textField.delegate = self
        textField.textColor = .white
        textField.placeholder = "0"
        textField.keyboardType = .decimalPad
        textField.setValue(Colors.textTips, forKeyPath: "_placeholderLabel.textColor")
        return textField
    }()
    
    private lazy var tradeSlider: UISlider = {
        let slider = CustomSlider()
        slider.addTarget(self, action: #selector(self.tradeSliderValueChanged(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(self.tradeSliderTouchEnd(_:)), for: .touchUpInside)
        return slider
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
    
    lazy var balanceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var coinTypeButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(selectedToken?.name.uppercased(), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.setImage(R.image.icon_down(), for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -30, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 60, bottom: 0, right: 0)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Colors.globalColor.cgColor
        button.addTarget(self, action: #selector(self.selectCoinTypeAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var withdrawButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.titleLabel?.font = UIFont.defaultFont(size: 16)
        button.setTitle(viewModel.submitButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.withdrawAction), for: .touchUpInside)
        return button
    }()
    
    let chainState: ChainState
    let style: Dex4DTradeViewStyle
    let navigationController: UINavigationController
    let viewModel: Dex4DTradeViewModel
    let accountViewModel: DexAccountViewModel
    
    var selectedToken: DexTokenObject?
    var tokenPools: [DexPool]?
    public var isInputValid: Bool = false
    public var transferAmount: String = "0"
    weak var delegate: WithdrawViewDelegate?
    
    init(
        style: Dex4DTradeViewStyle,
        chainState: ChainState,
        navigationController: UINavigationController,
        accountViewModel: DexAccountViewModel
    ) {
        self.style = style
        self.chainState = chainState
        self.navigationController = navigationController
        self.viewModel = Dex4DTradeViewModel(style: style, coin: "", chainState: chainState)
        self.accountViewModel = accountViewModel
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        self.backgroundColor = .clear
        self.selectedToken = accountViewModel.tokenObjects.first
        self.tokenPools = self.accountViewModel.pools?.filter { $0.tokenName == self.selectedToken?.name }
        if let pool = tokenPools?.first, let balance = pool.revenue {
            let balanceValue = balance == 0 ? "0" : String(balance)
            balanceLabel.text = "Available Withdrawal amount: ".localized + balanceValue + " " + pool.tokenName.uppercased()
            setupWithdrawButton(asset: balance)
        }
        configureSubviews()
        tradeTextField.addTarget(self, action: #selector(WithdrawView.textDidChanged(_:)), for: .editingChanged)
    }
    
    @objc private func tradeSliderValueChanged(_ sender: UISlider) {
        guard sender.value == 0 else {
            currentValueLabel.text = "\(Int(sender.value))%"
            return
        }
        currentValueLabel.text = nil
    }
    
    @objc private func tradeSliderTouchEnd(_ sender: UISlider) {
        if sender.value == 0 {
            tradeTextField.text = nil
            isInputValid = false
            return
        }
        tokenPools = accountViewModel.pools?.filter { $0.tokenName == selectedToken?.name }
        if let pool = tokenPools?.first, let balance = pool.revenue {
            isInputValid = true
            let cost = balance * Double(sender.value) / 100
            tradeTextField.text = cost == 0 ? "0" : cost.stringFloor6Value()
            transferAmount = String(cost)
        }
    }
    
    @objc private func selectCoinTypeAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let tokenObjects = self.accountViewModel.tokenObjects.filter { $0.tokenState != .advisor && $0.tokenState != .delist}
        tokenObjects.forEach { tokenObject in
            let action = UIAlertAction(title: tokenObject.name.uppercased(), style: .default) { action in
                self.coinTypeButton.setTitle(tokenObject.name.uppercased(), for: .normal)
                self.selectedToken = tokenObject
                self.tokenPools = self.accountViewModel.pools?.filter { $0.tokenName == self.selectedToken?.name }
                if let pool = self.tokenPools?.first, let balance = pool.revenue {
                    let balanceValue = balance == 0 ? "0" : String(balance)
                    self.balanceLabel.text = "Available Withdrawal amount: ".localized + balanceValue + " " + pool.tokenName.uppercased()
                    self.setupWithdrawButton(asset: balance)
                }
            }
            alertController.addAction(action)
        }
        let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil)
        alertController.addAction(cancel)
        navigationController.topViewController?.present(alertController, animated: true, completion: nil)
    }
    
    @objc private func withdrawAction() {
        delegate?.didPressedWithdraw(for: self)
    }
    
    @objc private func textDidChanged(_ textField: UITextField) {
        guard let text = textField.text, let count = Double(text), count != 0 else {
            tradeSlider.setValue(0, animated: true)
            currentValueLabel.text = nil
            isInputValid = false
            return
        }
        tokenPools = accountViewModel.pools?.filter { $0.tokenName == selectedToken?.name }
        if let pool = tokenPools?.first, let balance = pool.revenue {
            isInputValid = true
            var slideValue =  text.doubleValue.floor6Value() / balance.floor6Value()
            if slideValue > 1 {
                isInputValid = false
                slideValue = 1
            }
            tradeSlider.setValue(Float(slideValue * 100), animated: true)
            transferAmount = text
            currentValueLabel.text = "\(Int(slideValue * 100))%"
        }
    }
    
    func setupWithdrawButton(asset: Double) {
        if asset == 0 {
            withdrawButton.isEnabled = false
            withdrawButton.backgroundColor = UIColor(hex: "315968")
            withdrawButton.setTitleColor(UIColor(hex: "B7C5CA"), for: .normal)
        } else {
            withdrawButton.isEnabled = true
            withdrawButton.backgroundColor = Colors.globalColor
            withdrawButton.setTitleColor(.white, for: .normal)
        }
    }
    
    func configureSubviews() {
        addSubview(tradeTitleLabel)
        tradeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(24)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.centerX.equalToSuperview()
        }
        
        addSubview(coinTypeButton)
        coinTypeButton.snp.makeConstraints { (make) in
            make.top.equalTo(tradeTitleLabel.snp.bottom).offset(18)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        
        addSubview(textFieldBackground)
        textFieldBackground.snp.makeConstraints { (make) in
            make.centerY.equalTo(coinTypeButton)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.right.equalTo(coinTypeButton.snp.left).offset(-5)
            make.height.equalTo(coinTypeButton.snp.height)
        }
        
        textFieldBackground.addSubview(tradeTextField)
        tradeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.right.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview()
        }
        
        addSubview(tradeSlider)
        tradeSlider.snp.makeConstraints { (make) in
            make.top.equalTo(textFieldBackground.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(2 * Constants.leftPadding)
        }
        
        addSubview(minValueLabel)
        minValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tradeSlider.snp.bottom)
            make.left.equalTo(tradeSlider)
        }
        
        addSubview(currentValueLabel)
        currentValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.centerX.equalToSuperview()
        }
        
        addSubview(maxValueLabel)
        maxValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.right.equalTo(tradeSlider)
        }
        
        addSubview(balanceLabel)
        balanceLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.top.equalTo(maxValueLabel.snp.bottom).offset(20)
        }
        
        addSubview(withdrawButton)
        withdrawButton.snp.makeConstraints { (make) in
            make.top.equalTo(balanceLabel.snp.bottom).offset(48)
            make.left.equalToSuperview().offset(2 * Constants.leftPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.BaseButtonHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WithdrawView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard (textField.text?.isEmpty)! else {
            if textField.text!.contains(".") {
                if string == "." {
                    return false
                }
                let deRange = textField.text!.range(of: ".")
                let backStr = textField.text!.suffix(from: deRange!.upperBound)
                if backStr.count == DexConfig.decimals && string != "" {
                    return false
                }
                return true
            }
            if textField.text == "0" && (string != "." &&  string != "") {
                return false
            }
            return true
        }
        guard string == "." ||  string == "-" else {
            return true
        }
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


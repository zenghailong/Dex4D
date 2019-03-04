//
//  BuyDex4DView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt

enum Dex4DTradeViewStyle {
    case withdraw
    case buy(token: String, walletBalance: Double)
    case reinvest(token: String, reinvestBalance: Double)
    case sell(token: String, DexBalance: Double)
    case swap(token: String, DexBalance: Double)
}

protocol Dex4DTradeViewDelegate: class {
    func didPressedSubmitButton(in tradeView: Dex4DTradeView)
}

class Dex4DTradeView: UIView {
    
    let coin: String
    let chainState: ChainState
    let style: Dex4DTradeViewStyle
    let store: DexTokenStorage
    let navigationController: UINavigationController
    
    var selectedToken: DexTokenObject?
    var totalSupply: Double = 0
    
    public var isInputValid: Bool = false
    public var transferAmount: String = "0"
    public var recievedCount: String = "0"
    
    let viewModel: Dex4DTradeViewModel
    
    weak var delegate: Dex4DTradeViewDelegate?
    
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

    private lazy var priceLabel: UILabel = {
        let priceLabel = initTipLabel()
        switch style {
        case .swap:
            priceLabel.text = "Total Volume".localized + "0" +
                " " + (selectedToken?.name ?? "").uppercased()
        default:
            priceLabel.text = "Total Volume".localized + "0" +
                " " + coin.uppercased()
        }
        return priceLabel
    }()
    
    private lazy var gasLabel: UILabel = {
        let gasLabel = initTipLabel()
        gasLabel.text = String(format: "GAS consumption: %@ ETH".localized, "0")
        return gasLabel
    }()
    
    lazy var balanceLabel: UILabel = {
        let balanceLabel = initTipLabel()
        switch style {
        case .buy(let token, let walletBalance):
            let balanceValue = walletBalance == 0 ? "0" : walletBalance.stringFloor6Value()
            balanceLabel.text = "Wallet balance".localized + ": " + balanceValue + " " + token.uppercased()
        case .reinvest(let token, let reinvestBalance):
            let balanceValue = reinvestBalance == 0 ? "0" : reinvestBalance.stringFloor6Value()
            balanceLabel.text = "Reinvest balance".localized + ": " + balanceValue + " " + token.uppercased()
        case .sell(let token, let dexBalance):
            let balanceValue = dexBalance == 0 ? "0" : dexBalance.stringFloor6Value()
            balanceLabel.text = "D4D balance".localized + ": " + balanceValue + " " + "D4D"
        case .swap(let token, let dexBalance):
            let balanceValue = dexBalance == 0 ? "0" : dexBalance.stringFloor6Value()
            balanceLabel.text = "D4D balance".localized + ": " + balanceValue + " " + "D4D"
        default:
            break
        }
        return balanceLabel
    }()
    
    lazy var unitLabel: UILabel = {
        let unitLabel = UILabel()
        unitLabel.textColor = UIColor(hex: "44A0B6")
        unitLabel.font = UIFont.defaultFont(size: 14)
        unitLabel.text = "D4D"
        return unitLabel
    }()
    
    lazy var countLabel: UILabel = {
        let countLabel = initTipLabel()
        return countLabel
    }()
    
    private lazy var submitButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.globalColor
        button.titleLabel?.font = UIFont.defaultFont(size: 16)
        button.setTitle(viewModel.submitButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(self.tradeButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var swapTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Swap asset".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.icon_right())
        return imageView
    }()
    
    private lazy var selectTokenLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        label.text = selectedToken?.name.uppercased()
        return label
    }()
    private lazy var swapCoinTypeButton: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(self.selectCoinType), for: .touchUpInside)
        return button
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [
            priceLabel, gasLabel, balanceLabel, countLabel
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = 0
        return stackView
    }()
    
    init(
        style: Dex4DTradeViewStyle,
        coin: String,
        chainState: ChainState,
        store: DexTokenStorage,
        navigationController: UINavigationController
    ) {
        self.coin = coin
        self.style = style
        self.chainState = chainState
        self.viewModel = Dex4DTradeViewModel(style: style, coin: coin, chainState: chainState)
        self.store = store
        self.navigationController = navigationController
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 300))
        switch style {
        case .swap(let token, _):
            let tokensArr = store.tokens as? Array<[String: Any]>
            if let tokensArr = tokensArr {
                self.selectedToken = tokensArr.compactMap {
                        return DexTokenObject.deserialize(from: $0)
                    }.filter {
                        $0.tokenState == .regular && $0.name != token
                    }.sorted {
                        $0.name < $1.name
                    }.first
                let marketInfo = store.marketcapObjects.filter { $0.symbol == self.selectedToken?.name }.first
                if let marketInfo = marketInfo {
                    self.countLabel.text = marketInfo.symbol.uppercased() + "available D4D amount".localized + String(marketInfo.total_supply) + " D4D"
                    self.totalSupply = marketInfo.total_supply
                }
            }
        default:
            self.selectedToken = .none
        }
        initSubViews()
        let gas = EtherNumberFormatter.full.string(from: self.viewModel.calculatedGasUsed(), units: .ether)
        gasLabel.text = String(format: "GAS consumption: %@ ETH".localized, gas.doubleValue.stringFloor6Value())
    }
    
    private func getFormatterPriceNumber(_ value: String) -> String {
        let bigNum = BigInt(value) ?? BigInt()
        let price =  EtherNumberFormatter.full.string(from: bigNum, decimals: DexConfig.decimals)
        return price.doubleValue.stringFloor8Value()
    }
    
    @objc private func tradeButtonAction() {
        switch style {
        case .swap:
            let inputAmount = tradeTextField.text?.doubleValue ?? 0
            guard totalSupply < inputAmount else {
               delegate?.didPressedSubmitButton(in: self)
               return
            }
            if LocalizationTool.shared.currentLanguage == .english {
                navigationController.topViewController?.showTipsMessage(message: String(format: "Insufficient %@ amount, Swap option failed. Please reset D4D Sell amount", (selectedToken?.name ?? "").uppercased()))
            } else {
                navigationController.topViewController?.showTipsMessage(message: String(format: "%@ 数量不足，无法进行对倒，请调整卖出D4D数量", (selectedToken?.name ?? "").uppercased()))
            }
            
        default:
            delegate?.didPressedSubmitButton(in: self)
        }
        
    }
    
    @objc private func selectCoinType() {
        switch style {
        case .swap(let token, _):
            let tokensArr = store.tokens as? Array<[String: Any]>
            if let tokensArr = tokensArr {
                let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let filterTokens = tokensArr.compactMap {
                        return DexTokenObject.deserialize(from: $0)
                    }.filter {
                        $0.tokenState == .regular
                    }.sorted {
                        $0.name < $1.name
                    }
                let tokenObjects = filterTokens.filter { $0.name != token }
                tokenObjects.forEach { tokenObject in
                    let action = UIAlertAction(title: tokenObject.name.uppercased(), style: .default) { _ in
                        self.selectTokenLabel.text = tokenObject.name.uppercased()
                        self.selectedToken = tokenObject
                        self.tradeTextField.text = nil
                        self.tradeSlider.value = 0
                        let marketInfo = self.store.marketcapObjects.filter { $0.symbol == self.selectedToken?.name}.first
                        if let marketInfo = marketInfo {
                            self.countLabel.text = marketInfo.symbol.uppercased() + "available D4D amount".localized + String(marketInfo.total_supply) + " D4D"
                            self.totalSupply = marketInfo.total_supply
                        }
                    }
                    alertController.addAction(action)
                }
                let cancel = UIAlertAction.init(title: "Cancel".localized, style: .cancel, handler: nil)
                alertController.addAction(cancel)
                self.navigationController.topViewController?.present(alertController, animated: true, completion: nil)
            }
        default:
            break
        }
    }
    
    @objc private func tradeSliderValueChanged(_ sender: UISlider) {
        guard sender.value == 0 else {
           currentValueLabel.text = "\(Int(sender.value))%"
            return
        }
        currentValueLabel.text = nil
    }
    
    @objc private func tradeSliderTouchEnd(_ sender: UISlider) {
        switch style {
        case .buy(let token, let balance), .reinvest(let token, let balance):
            if sender.value == 0 {
                tradeTextField.text = nil
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + token.uppercased()
                isInputValid = false
                return
            }
            let cost = balance * Double(sender.value) / 100.0
            guard cost != 0 else { return }
            viewModel.getDex4DCount(tokenValue: cost.stringFloor6Value(), symbol: token) {[weak self] count in
                self?.isInputValid = true
                self?.tradeTextField.text = count.replacingOccurrences(of: ",", with: "")
                self?.priceLabel.text = "Total Volume".localized + cost.stringFloor6Value() +
                    " " + token.uppercased()
                //self?.countLabel.text = "Spend: ".localized + cost.stringFloor6Value() + " " + token.uppercased()
                self?.transferAmount = cost.stringFloor6Value()
            }
        case .sell(let token, let balance):
            if sender.value == 0 {
                tradeTextField.text = nil
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + token.uppercased()
                isInputValid = false
                return
            }
            let cost = balance * Double(sender.value) / 100.0
            guard cost != 0 else { return }
            viewModel.getTokenReceivedCount(dexCount: cost.stringFloor6Value(), symbol: token) { [weak self] count in
                self?.isInputValid = true
                self?.tradeTextField.text = cost.stringFloor6Value()
                self?.priceLabel.text = "Total Volume".localized + count +
                    " " + token.uppercased()
                //self?.countLabel.text = "Receive: ".localized + count + " " + token.uppercased()
                self?.transferAmount = String(cost)
                self?.recievedCount = count
            }
        case .swap(_, let balance):
            guard let selectedToken = selectedToken else { return }
            if sender.value == 0 {
                tradeTextField.text = nil
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + selectedToken.name.uppercased()
                isInputValid = false
                return
            }
            let cost = balance * Double(sender.value) / 100.0
            guard cost != 0 else { return }
            viewModel.getTokenReceivedCount(dexCount: cost.stringFloor6Value(), symbol: selectedToken.name) { [weak self] count in
                self?.isInputValid = true
                self?.tradeTextField.text = cost.stringFloor6Value()
                self?.priceLabel.text = "Total Volume".localized + count +
                    " " + selectedToken.name.uppercased()
               // self?.countLabel.text = "Receive: ".localized + count + " " + selectedToken.name.uppercased()
                self?.transferAmount = String(cost)
                self?.recievedCount = count
            }
        default:
            break
        }
    }
    
    func reset() {
        tradeTextField.text = nil
        tradeSlider.setValue(0, animated: false)
        currentValueLabel.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initTipLabel() -> UILabel {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 12)
        return label
    }
    
    private func initSubViews() {
        
        addSubview(tradeTitleLabel)
        tradeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(15)
            make.left.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
        }
        
        switch style {
        case .swap(_):
            tradeTitleLabel.snp.updateConstraints { (make) in
                make.top.equalToSuperview().offset(65)
            }
            
            addSubview(swapTitleLabel)
            swapTitleLabel.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(15)
                make.left.equalToSuperview().offset(15)
            }
            
            addSubview(arrowImageView)
            arrowImageView.snp.makeConstraints { (make) in
                make.right.equalToSuperview().offset(-8)
                make.centerY.equalTo(swapTitleLabel)
            }
            
            addSubview(selectTokenLabel)
            selectTokenLabel.snp.makeConstraints { (make) in
                make.right.equalTo(arrowImageView.snp.left).offset(-2)
                make.centerY.equalTo(swapTitleLabel)
            }
            
            addSubview(swapCoinTypeButton)
            swapCoinTypeButton.snp.makeConstraints { (make) in
                make.centerY.equalTo(swapTitleLabel)
                make.left.right.equalToSuperview()
                make.height.equalTo(40)
            }
            
            let line = UIView()
            line.backgroundColor = UIColor(hex: "272733")
            self.addSubview(line)
            line.snp.makeConstraints { (make) in
                make.top.equalTo(swapTitleLabel.snp.bottom).offset(15)
                make.left.right.equalToSuperview()
                make.height.equalTo(1)
            }
        default: break
        }
        
        self.addSubview(textFieldBackground)
        textFieldBackground.snp.makeConstraints { (make) in
            make.top.equalTo(tradeTitleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
        }
        
        textFieldBackground.addSubview(tradeTextField)
        tradeTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview()
        }
        textFieldBackground.addSubview(unitLabel)
        unitLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalToSuperview()
        }
        
        self.addSubview(tradeSlider)
        tradeSlider.snp.makeConstraints { (make) in
            make.top.equalTo(tradeTextField.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(15)
        }
        
        self.addSubview(minValueLabel)
        minValueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tradeSlider.snp.bottom)
            make.left.equalTo(tradeSlider)
        }
        
        self.addSubview(currentValueLabel)
        currentValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.centerX.equalToSuperview()
        }
        
        self.addSubview(maxValueLabel)
        maxValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(minValueLabel)
            make.right.equalTo(tradeSlider)
        }
        
        self.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(minValueLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.height.equalTo(80)
        }
        
        self.addSubview(submitButton)
        submitButton.snp.makeConstraints { (make) in
            make.top.equalTo(stackView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.BaseButtonHeight)
        }
    }
}

extension Dex4DTradeView: UITextFieldDelegate {
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
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch style {
        case .buy(let token, let balance), .reinvest(let token, let balance):
            guard let text = textField.text, let count = Double(text), count != 0 else {
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + token.uppercased()
                tradeSlider.setValue(0, animated: true)
                currentValueLabel.text = nil
                isInputValid = false
                return
            }
            viewModel.getTokenSpendCount(coin: token, count: count.stringFloor6Value()) {[weak self] (cost) in
                self?.isInputValid = true
                var slideValue =  cost.doubleValue.floor6Value() / balance.floor6Value()
                if slideValue > 1 {
                    self?.isInputValid = false
                    slideValue = 1
                }
                self?.tradeSlider.setValue(Float(slideValue * 100), animated: true)
                self?.priceLabel.text = "Total Volume".localized + cost +
                    " " + token.uppercased()
                self?.currentValueLabel.text = slideValue == 0 ? "" : "\(Int(slideValue * 100))%"
                self?.transferAmount = cost
            }
        case .sell(let token, let balance):
            guard let text = textField.text, let count = Double(text), count != 0 else {
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + token.uppercased()
                tradeSlider.setValue(0, animated: true)
                currentValueLabel.text = nil
                isInputValid = false
                return
            }
            viewModel.getTokenReceivedCount(dexCount: text.doubleValue.stringFloor6Value(), symbol: token) { [weak self] count in
                self?.isInputValid = true
                var slideValue = text.doubleValue.floor6Value() / balance
                if slideValue > 1 {
                    self?.isInputValid = false
                    slideValue = 1
                }
                self?.tradeSlider.setValue(Float(slideValue * 100), animated: true)
                self?.priceLabel.text = "Total Volume".localized + count +
                    " " + token.uppercased()
                self?.currentValueLabel.text = slideValue == 0 ? "" : "\(Int(slideValue * 100))%"
                self?.transferAmount = text
                self?.recievedCount = count
            }
        case .swap(_, let balance):
            guard let selectedToken = selectedToken else { return }
            guard let text = textField.text, let count = Double(text), count != 0 else {
                priceLabel.text = "Total Volume".localized + "0" +
                    " " + selectedToken.name.uppercased()
                tradeSlider.setValue(0, animated: true)
                currentValueLabel.text = nil
                isInputValid = false
                return
            }
            viewModel.getTokenReceivedCount(dexCount: text.doubleValue.stringFloor6Value(), symbol: selectedToken.name) { [weak self] count in
                self?.isInputValid = true
                var slideValue = text.doubleValue.floor6Value() / balance
                if slideValue > 1 {
                    self?.isInputValid = false
                    slideValue = 1
                }
                self?.tradeSlider.setValue(Float(slideValue * 100), animated: true)
                self?.priceLabel.text = "Total Volume".localized + count +
                    " " + selectedToken.name.uppercased()
                self?.currentValueLabel.text = slideValue == 0 ? "" : "\(Int(slideValue * 100))%"
                self?.transferAmount = text
                self?.recievedCount = count
            }
        default:
            break
        }
        
    }
}

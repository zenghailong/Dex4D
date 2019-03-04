//
//  SendTokenView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/17.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

protocol SendTokenViewDelegate: class {
    func didSelectScan()
    func textChanged()
}

class SendTokenView: UIView {
    
    weak var delegate: SendTokenViewDelegate?
    
    @IBOutlet weak var seleTokenLabel: UILabel!
    @IBOutlet weak var selectTokenButton: UIButton!
    @IBOutlet weak var receiveAddressView: UIView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var sendAmountView: UIView!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var selectLabel: UILabel!
    @IBOutlet weak var tokenAmountLabel: UILabel!
    @IBOutlet weak var receiveAddressLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var tokenLabel: UILabel!
    
    var selectTokenBlock: (() -> Void)?

    var sendViewModel: SendViewModel? {
        didSet {
            if let address = sendViewModel?.address {
                addressTextField.text = address
            }
            if let token = sendViewModel?.tokenType {
                tokenLabel.text = token
            }
            checkContinueButtonStatus()
        }
    }
    
    @objc dynamic var inputInfoValid: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiveAddressView.backgroundColor = Colors.cellBackground
        receiveAddressView.layer.cornerRadius = Constants.cornerRadius
        receiveAddressView.layer.masksToBounds = true
        sendAmountView.backgroundColor = Colors.cellBackground
        sendAmountView.layer.cornerRadius = Constants.cornerRadius
        sendAmountView.layer.masksToBounds = true
        
        receiveAddressView.layer.shadowColor = UIColor(hex: "22222C").cgColor
        receiveAddressView.layer.shadowOffset = CGSize.zero
        receiveAddressView.layer.shadowOpacity = 1
        receiveAddressView.layer.shadowRadius = 33

        sendAmountView.layer.shadowColor = UIColor(hex: "22222C").cgColor
        sendAmountView.layer.shadowOffset = CGSize.zero
        sendAmountView.layer.shadowOpacity = 1
        sendAmountView.layer.shadowRadius = 33
        
        amountTextField.keyboardType = .decimalPad
        amountTextField.delegate = self
        addressTextField.delegate = self
        
        addressTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
        amountTextField.addTarget(self, action: #selector(self.textDidChanged(_:)), for: .editingChanged)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:))))
        
        seleTokenLabel.text = "Select token".localized
        receiveAddressLabel.text = "Receive address".localized
        tokenAmountLabel.text = "Token amount".localized
        balanceLabel.text = "Wallet balance".localized + ": --"
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            if amountTextField.isFirstResponder {
                amountTextField.resignFirstResponder()
            }
            if addressTextField.isFirstResponder {
                addressTextField.resignFirstResponder()
            }
        }
        sender.cancelsTouchesInView = false
    }
    
    @objc func textDidChanged(_ textField: UITextField) {
        checkContinueButtonStatus()
    }
    
    private func checkContinueButtonStatus() {
        if let addressStr = addressTextField.text, let amountStr = amountTextField.text {
            if !addressStr.isEmpty && !amountStr.isEmpty {
                inputInfoValid = true
            } else {
                inputInfoValid = false
            }
        }
        delegate?.textChanged()
    }
    
    @IBAction func getMaxAmount(_ sender: Any) {
        if let token = sendViewModel?.tokenObject {
            amountTextField.text = Double(token.value) == 0 ? "0" : Double(token.value)?.stringFloor6Value()
            checkContinueButtonStatus()
        }
    }
    
    @IBAction func scan(_ sender: Any) {
        delegate?.didSelectScan()
    }
    
    @IBAction func selectToken(_ sender: Any) {
        selectTokenBlock?()
    }
    
    func refresh() {
        tokenLabel.text = sendViewModel?.tokenObject?.symbol
        amountTextField.text = nil
        checkContinueButtonStatus()
        if let tokenObject = sendViewModel?.tokenObject {
            let balance = sendViewModel!.showBalance(for: tokenObject)
            let balanceValue = Double(balance) == 0 ? "0" : balance
            balanceLabel.text = "Wallet balance".localized + ": " + balanceValue + " " + tokenObject.symbol
        }
    }
}

extension SendTokenView: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == addressTextField {
            if string == " " {
                return false
            }
            return true
        } else {
            guard (textField.text?.isEmpty)! else {
                if textField.text!.contains(".") {
                    if string == "." {
                        return false
                    }
                    let deRange = textField.text!.range(of: ".")
                    let backStr = textField.text!.suffix(from: deRange!.upperBound)
                    if backStr.count == sendViewModel?.server.decimals && string != "" {
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
    }
}

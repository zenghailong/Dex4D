//
//  SendViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/17.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

protocol SendViewControllerDelegate: class {
    func didPressSelectToken(in viewController: UIViewController)
    func didCancel(in viewController: UIViewController)
    func didPressContinue(
        transaction: UnconfirmedTransaction,
        transfer: Transfer,
        token: TokenObject,
        in viewController: SendViewController
    )
}

class SendViewController: BaseViewController {
    
    weak var delegate: SendViewControllerDelegate?
    
    var selectedToken: TokenObject?
    
    var transfer: Transfer?
    
    let viewModel: SendViewModel
    
    var myContext = NSObject()
    
    lazy var sendTokenView: SendTokenView = {
        let sendTokenView = R.nib.sendTokenView.firstView(owner: nil, options: nil)
        sendTokenView?.sendViewModel = viewModel
        let view = sendTokenView ?? SendTokenView ()
        view.delegate = self
        return view
    }()
    
    lazy var continueButton: UIButton = {
        let continueButton = UIButton(type: .custom)
        continueButton.setTitle(viewModel.continueButtonText, for: .normal)
        continueButton.setTitleColor(Colors.buttonInvalidText, for: .normal)
        continueButton.backgroundColor = Colors.buttonInvalid
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        continueButton.layer.cornerRadius = Constants.BaseButtonHeight / 2
        continueButton.isEnabled = false
        continueButton.addTarget(self, action: #selector(SendViewController.continueAction), for: .touchUpInside)
        return continueButton
    }()
    
    private var data = Data()
    
    init(viewModel: SendViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.titleText
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: ScanViewController.self) == false
            }
        }
        
        view.addSubview(sendTokenView)
        sendTokenView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(340)
        }
        
        view.addSubview(continueButton)
        continueButton.snp.makeConstraints { (make) in
            make.top.equalTo(sendTokenView.snp.bottom)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(Constants.BaseButtonHeight)
        }
        
        if let token = viewModel.getToken() {
            setSelectToken(token: token)
        }
        checkContinueButtonStatus()
        sendTokenView.selectTokenBlock = {[weak self] in
            guard let strongSelf = self else {
                return
            }
            strongSelf.delegate?.didPressSelectToken(in: strongSelf)
        }
        sendTokenView.addObserver(self, forKeyPath: "inputInfoValid", options: .new, context: &myContext)
        NotificationCenter.default.addObserver(self, selector: #selector(self.didSelectedToken(_:)), name: NotificationNames.selectedTokenNotify, object: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            checkContinueButtonStatus()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func didSelectedToken(_ notify: Notification) {
        if let token = notify.object as? TokenObject {
            setSelectToken(token: token)
        }
    }
    
    private func setSelectToken(token: TokenObject) {
        selectedToken = token
        sendTokenView.sendViewModel?.tokenObject = token
        sendTokenView.refresh()
        if let token = selectedToken {
            if viewModel.server.symbol == token.symbol {
                transfer = Transfer(server: viewModel.server, type: .ether(token, destination: .none))
            } else {
                transfer = Transfer(server: viewModel.server, type: .token(token))
            }
        }
        
    }
    
    @objc func continueAction() {
        guard let transfer = transfer else {
            showTipsMessage(message: Errors.emptyToken.errorDescription)
            return
        }
        let addressString = sendTokenView.addressTextField.text?.trimmed ?? ""
        if let _ = EthereumAddressRule.isValid(address: addressString) {
            showTipsMessage(message: Errors.invalidAddress.errorDescription)
            return
        }
        let amountString = sendTokenView.amountTextField.text
        if let amount = amountString {
            if amount.doubleValue <= 0 {
                showTipsMessage(message: Errors.wrongInput.errorDescription)
                return
            }
            if let token = selectedToken, amount.doubleValue > token.value.doubleValue  {
                showTipsMessage(message: Errors.balanceNotEnough.errorDescription)
                return
            }
        }
        
        let parsedValue: BigInt? = {
            switch transfer.type {
            case .ether, .dapp:
                return EtherNumberFormatter.full.number(from: amountString!, units: .ether)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString!, decimals: token.decimals)
            }
        }()
        
        guard let value = parsedValue else {
            showTipsMessage(message: Errors.invalidAmount.errorDescription)
            return 
        }
        
        let transaction = UnconfirmedTransaction(
            transfer: transfer,
            value: value,
            to: EthereumAddress(string: addressString),
            data: data,
            gasLimit: .none,
            gasPrice: viewModel.gasPrice,
            nonce: .none
        )
        delegate?.didPressContinue(transaction: transaction, transfer: transfer, token: selectedToken!, in: self)
    }
    
    private func checkContinueButtonStatus() {
        if sendTokenView.inputInfoValid , let _ = selectedToken {
            continueButton.isEnabled = true
            continueButton.backgroundColor = Colors.globalColor
            continueButton.setTitleColor(.white, for: .normal)
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = Colors.buttonInvalid
            continueButton.setTitleColor(Colors.buttonInvalidText, for: .normal)
        }
    }
    
    deinit {
        delegate?.didCancel(in: self)
        sendTokenView.removeObserver(self, forKeyPath: "inputInfoValid", context: &myContext)
    }
    
}

extension SendViewController: SendTokenViewDelegate {
    func textChanged() {
        checkContinueButtonStatus()
    }
    func didSelectScan() {
//        let vc = ScanViewController()
//        vc.hidesBottomBarWhenPushed = true
//        vc.delegate = self
//        navigationController?.pushViewController(vc, animated: true)
    }
}

//extension SendViewController: ScanViewControllerDelegate {
//    func didScanQRCode(result: String) {
//        if result.hasPrefix("0x") || result.hasPrefix("0X") {
//            sendTokenView.addressTextField.text = result
//            navigationController?.popViewController(animated: true )
//        } else {
//            let vc = ScanResultViewController()
//            vc.resultString = result
//            navigationController?.pushViewController(vc, animated: true)
//        }
//    }
//}

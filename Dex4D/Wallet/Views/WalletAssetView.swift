//
//  WalletAssetView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/16.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

enum assetAction: String {
    case receive = "receive"
    case send  = "send"
    case viewHistory = "history"
}

protocol WalletAssetViewDelegate: class {
    func didPressedActionButton(type: assetAction, in assetView: WalletAssetView)
    func didSelectSwitch()
}

class WalletAssetView: UIView {
    
    weak var delegate: WalletAssetViewDelegate?
    
    var totalBalance: String = "0.00"
    var isHideAsset: Bool {
        get {
            return UserDefaults.getBoolValue(for: Dex4DKeys.isHideWalletAsset)
        }
        set {
            UserDefaults.setBoolValue(value: newValue, key: Dex4DKeys.isHideWalletAsset)
        }
    }
    
    @IBOutlet weak var titleDescLabel: UILabel!
    @IBOutlet weak var totalAssetLabel: UILabel!
    @IBOutlet weak var hideAssetButton: UIButton!
    
    @IBOutlet weak var receiveButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var historyButton: UIButton!
    @IBOutlet weak var receiveLabel: UILabel!
    @IBOutlet weak var sendLabel: UILabel!
    @IBOutlet weak var historyLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        receiveLabel.text = "Receive".localized
        sendLabel.text = "Send".localized
        historyLabel.text = "History".localized
        
        receiveButton.backgroundColor = Colors.globalColor
        receiveButton.tag = 100
        receiveButton.layer.cornerRadius = 10
        receiveButton.layer.masksToBounds = true
        receiveButton.addTarget(self, action: #selector(WalletAssetView.clickedAction(_:)), for: .touchUpInside)
        
        sendButton.backgroundColor = Colors.globalColor
        sendButton.tag = 101
        sendButton.layer.cornerRadius = 10
        sendButton.layer.masksToBounds = true
        sendButton.addTarget(self, action: #selector(WalletAssetView.clickedAction(_:)), for: .touchUpInside)
        
        historyButton.backgroundColor = Colors.globalColor
        historyButton.tag = 102
        historyButton.layer.cornerRadius = 10
        historyButton.layer.masksToBounds = true
        historyButton.addTarget(self, action: #selector(WalletAssetView.clickedAction(_:)), for: .touchUpInside)
    }
    
    @objc func clickedAction(_ sender: DexButton) {
        var action: assetAction
        switch sender.tag {
        case 100:
            action = .receive
        case 101:
            action = .send
        default:
            action = .viewHistory
        }
        delegate?.didPressedActionButton(type: action, in: self)
    }
    
    func setTotalAsset(value: String? = nil) {
        titleDescLabel.text = String(format: "Total asset (%@)".localized, LocalizationTool.shared.currentCurrency.string())
        if let balance = value {
            totalBalance = balance
        }
        if isHideAsset {
            hideAssetButton.setImage(R.image.icon_eye_close_wallet(), for: .normal)
            totalAssetLabel.text = Dex4DKeys.hideAssetSymbol
        } else {
            hideAssetButton.setImage(R.image.icon_eye_open_wallet(), for: .normal)
            totalAssetLabel.text = LocalizationTool.shared.currentCurrency.symbol() + totalBalance
        }
    }
    
    @IBAction func hideAssetButtonAction(_ sender: UIButton) {
        isHideAsset = !isHideAsset
        setTotalAsset()
        delegate?.didSelectSwitch()
    }
    
}


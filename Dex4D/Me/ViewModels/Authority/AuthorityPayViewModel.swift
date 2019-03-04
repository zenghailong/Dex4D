//
//  ReferralPayViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/24.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol AuthorityPayViewModelDelegate: class {
    func dex4DBalanceValueChanged()
    func ethBalanceValueChanged()
    func ethCountValueChanged()
    func authorityValueChanged()
}

class AuthorityPayViewModel: NSObject {
    
    weak var delegate: AuthorityPayViewModelDelegate?
    
    @objc dynamic var titleLabelText = ""
    
    var pendingTitleLabelText = "Payment pending".localized
    var foreverLabelText: NSMutableAttributedString {
        let str = String(format: "You have permanent %@ authority now. Enjoy to trade with your %@".localized, authorityOperation.stringValue.localized, authorityOperation.stringValue.localized)
        return str.toAttributedString()
    }
    var pendingLabelText: NSMutableAttributedString {
        let str = String(format: "You have paid for permanent %@ authority\nPlease be more patient before Ethereum confirm this trasaction".localized, authorityOperation.stringValue.localized)
        return str.toAttributedString()
    }
    
    
    
    @objc dynamic var progress: CGFloat = 0.0
    
    @objc dynamic var payDex4DTitleLabelText = ""
    
    @objc dynamic var payDex4DBalanceLabelText = ""
    
    @objc dynamic var payDex4DSubmitButtonText = "Referral code".localized
    
    
    
    @objc dynamic var payETHTitleLabelText = ""
    
    @objc dynamic var payETHBalanceLabelText = ""
    
    @objc dynamic var payETHSubmitButtonText = ""
    
    
    
    var ethCount: Double = 0 {
        didSet {
            switch authorityOperation.operation {
            case .referral:
                titleLabelText = String(format: "Owning %@ D4D or Paying %@ ETH unlocks the Masternode/Referral system".localized, authorityOperation.dex4DCount.stringIntValue(), ethCount.stringValue())
            case .swap:
                titleLabelText = String(format: "Owning %@ D4D or Paying %@ ETH unlocks the Swap transaction masternode".localized, authorityOperation.dex4DCount.stringIntValue(), ethCount.stringValue())
            }
            payETHTitleLabelText = String(format: "Pay %@ ETH to become Permanent %@ masternode".localized, ethCount.stringValue(), authorityOperation.stringValue.localized)
            payETHSubmitButtonText = String(format: "Pay %@ ETH".localized, ethCount.stringValue())
            delegate?.ethCountValueChanged()
        }
    }
    
    var ethBalance: Double = 0 {
        didSet {
            payETHBalanceLabelText = String(format: "Acailable wallet amount: %@".localized, ethBalance.stringFloor6Value())
            delegate?.ethBalanceValueChanged()
        }
    }
        
    var dex4DBalance: Double = 0 {
        didSet {
            payDex4DBalanceLabelText = String(format: "Current D4D amount: %@".localized, dex4DBalance.stringFloor6Value())
            let value = CGFloat(dex4DBalance / authorityOperation.dex4DCount)
            progress = value > 1 ? 1 : value
            delegate?.dex4DBalanceValueChanged()
        }
    }
    
    var authorityOperation: AuthorityOperation {
        didSet {
            switch authorityOperation.authority {
            case .forever:
                payDex4DTitleLabelText = "Permanent available".localized
            case .temp:
                payDex4DTitleLabelText = "Temporary available".localized
            case .none:
                payDex4DTitleLabelText = "Not available".localized
            default:
                payDex4DTitleLabelText = ""
            }
            delegate?.authorityValueChanged()
        }
    }
    
    let account: WalletInfo
    let tokensStorage: TokensDataStore
    var dexAccountInfo: [String: Any]?
    var d4d: [String: Any]? {
        if let dexAccountInfo = dexAccountInfo {
            guard dexAccountInfo.keys.contains(AccountInfo.d4d.description) else { return nil }
            return dexAccountInfo[AccountInfo.d4d.description] as? [String: Any]
        }
        return nil
    }
    
    init(
        account: WalletInfo,
        operation: AuthorityOperation.Operation,
        tokensStorage: TokensDataStore
    ) {
        self.account = account
        self.authorityOperation = AuthorityOperation(operation: operation)
        self.tokensStorage = tokensStorage
        super.init()
        
        getEthBalance()
        getEthCount()
        getDex4DBalance()
        
        switch operation {
        case .referral:
            getReferralAuthority()
        case .swap:
            getSwapAuthority()
        }
    }
    
    func getEthCount() {
        Dex4DProvider.shared.getEthCountByDex4DOperation(operation: authorityOperation.operation) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let count):
                self.ethCount = count
                UserDefaults.setDoubleValue(value: count, key: self.authorityOperation.stringValue + self.account.currentAccount.address.description)
                print("ethcount = \(count)")
            case .failure(_):
                break
            }
        }
    }
    
    func getEthBalance() {
        if let token = tokensStorage.ethereumObject {
            let vm = TokenViewModel.balance(for: token, wallet: account)
            vm?.balance(completion: { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    self.ethBalance = balance.amountShort.doubleValue
                    print("ethbalance = \(balance)")
                case .failure(_):
                    break
                }
            })
        }
    }
    
    func getDex4DBalance() {
        Dex4DProvider.shared.getDex4DBalance(address: account.currentAccount.address.description) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                if let d4d = data["d4d"] as? [String: Any] {
                    if let total = d4d["total"] as? Double {
                        self.dex4DBalance = total.floor6Value()
                        print("d4dbalance = \(total)")
                    }
                }
            case .failure(_):
                break
            }
        }
    }
    
    func getReferralAuthority() {
        Dex4DProvider.shared.hasDex4DReferralAuthority(address: account.currentAccount.address.description) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let flag):
                print("referral = \(flag)")
                self.setAuthority(flag: flag)
            case .failure(_):
                break
            }
        }
    }
    
    func getSwapAuthority() {
        Dex4DProvider.shared.hasDex4DSwapAuthority(address: account.currentAccount.address.description) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let flag):
                print("swap = \(flag)")
                self.setAuthority(flag: flag)
            case .failure(_):
                break
            }
        }
    }
    
    private func setAuthority(flag: Int = -1) {
        if flag == 0 {
            self.authorityOperation.authority = .none
        } else if flag == 1 {
            self.authorityOperation.authority = .forever
        } else if flag == 2 {
            self.authorityOperation.authority = .pending
        } else {
            self.authorityOperation.authority = .unknow
        }
    }
    
    func setDefaultValue() {
        ethCount = UserDefaults.getDoubleValue(for: authorityOperation.stringValue + account.currentAccount.address.description)
        ethBalance = 0
        dex4DBalance = 0
        setAuthority()
    }
    
}

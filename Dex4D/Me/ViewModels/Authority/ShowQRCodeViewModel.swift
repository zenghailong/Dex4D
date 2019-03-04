//
//  ReferralViewModel.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/30.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol ShowQRCodeViewModelDelegate: class {
    func linkLabelTextValueChanged()
}

class ShowQRCodeViewModel: NSObject {
    
    weak var delegate: ShowQRCodeViewModelDelegate?
    
    @objc dynamic var linkLabelText = "" {
        didSet {
            delegate?.linkLabelTextValueChanged()
        }
    }
    
    @objc dynamic var amount: Double = 0 {
        didSet {
            delegate?.linkLabelTextValueChanged()
        }
    }
    
    var imageSize: CGSize {
        return CGSize(width: 168, height: 168)
    }
    
    var amountButtonText: String {
        return "Set amount".localized
    }
    
    var saveButtonText: String {
        return "Long press to save".localized
    }
    
    var copyButtonText: String {
        switch type {
        case .wallet:
            return "Copy address".localized
        case .referral:
            return "Copy link".localized
        }
    }
    
    let type: ShowQRCodeType
    let address: String
    
    init(address: String, showType: ShowQRCodeType) {
        self.address = address
        self.type = showType
        super.init()
    }
    
    private func getNickName() {
        Dex4DProvider.shared.getDex4DReferralUserName(address: address) {  [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let str):
                let name = str == "" ? self.address : str
                self.linkLabelText = Dex4DUrls.exchange + name
                UserDefaults.setStringValue(value: name, key: Dex4DKeys.nickName + self.address)
                break
            case .failure(_):
                break
            }
        }
    }
    
    func setDefaultValue() {
        if type == .wallet {
            linkLabelText = address
        } else {
            linkLabelText = Dex4DUrls.exchange + UserDefaults.getStringValue(for: Dex4DKeys.nickName + address)
            getNickName()
        }
    }
    
}

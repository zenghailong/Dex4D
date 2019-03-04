//
//  ReceiveTokenViewModel.swift
//  Dex4D
//
//  Created by zeng hai long on 17/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

struct ReceiveTokenViewModel {
    
    let wallet: Account
    
    var titleText: String {
        return "Receive".localized
    }
    
    var buttonTitleText: String {
        return "Copy address".localized
    }
    
    var qrImage: UIImage {
        let size = Constants.ScreenWidth - 14 * Constants.leftPadding
        return UIImage.createQRCodeImage(content: wallet.address.description, size: CGSize(width: size, height: size))
    }
    
    init(wallet: Account) {
        self.wallet = wallet
    }
}

//
//  Constants.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/26.
//  Copyright © 2018年 龙. All rights reserved.
//

import Foundation
import UIKit

public struct Constants {
    public static let ScreenWidth = UIScreen.main.bounds.size.width
    public static let ScreenHeight = UIScreen.main.bounds.size.height
    public static let ScaleWidth = Constants.ScreenWidth / 375.0
    public static let ScaleHeight = Constants.ScreenHeight / 667.0
    public static let ScaleSize = Constants.ScreenWidth > 1 ? Constants.ScreenWidth : 1
    
    public static let StatusBarHeight = UIApplication.shared.statusBarFrame.size.height
    public static let NavigationBarHeight = Constants.StatusBarHeight + 44
    public static let TabBarHeight: CGFloat = Constants.StatusBarHeight > 20 ? 83 : 49
    public static let BottomBarHeight: CGFloat = Constants.StatusBarHeight > 20 ? 34 : 0
    
    public static let IS_iPhoneX = Constants.StatusBarHeight > 20 ? true : false
    
    public static let BaseButtonHeight: CGFloat = 42
    
    public static let leftPadding: CGFloat = 15
    
    public static let cornerRadius: CGFloat = 6
}

public struct Dex4DKeys {
    public static let keychainKeyPrefix = "Dex4D"
    public static let fontName = "Helvetica"
    public static let language = "Language"
    public static let currency = "Currency"
    public static let nickName = "NickName"
    public static let isHideHomeAsset = "IsHideAsset"
    public static let isHideWalletAsset = "IsHideWalletAsset"
    public static let hideAssetSymbol = "******"
    
    public static let initialWalletDoneKey = "InitialWalletDoneKey"
    public static let invitationCode = "InvitationCode"
    public static let touchId = "TouchId"
    public static let touchIdUnlock = "TouchIdUnlock"
    
    public static let md5PrivateKey = "&vhApB5tqn53Gt7NMvC4k"
}

public struct Dex4DUrls {
    public static let httpServerBase = "http://106.75.25.3:8603"
    public static let scanServerBase = "http://106.75.25.3:8668"
    public static let tokenTransactionBase = "http://106.75.25.3:8669"
    public static let websocketServerBase = "http://106.75.25.3:8604"
    
    //    public static let base = "https://dex4d.io/"
    //    public static let base = "http://117.50.16.115:8608/"
    public static let base = "http://172.16.1.148:8081/"
    public static let exchange = Dex4DUrls.base + "exchange/"
    //    public static let bowserHome = "http://114.115.212.109:8080/demo/DappHtml/index.html"
    public static let bowserHome = Dex4DUrls.exchange
    
    public static let wiki = "https://wiki.dex4d.io"
    
    public static let hash = "https://rinkeby.etherscan.io/tx/"
    // TODO
    public static let rpc = "https://rinkeby.infura.io/v3/2c82bfee14df4a73b6af601f0258beb5"
}

public struct Colors {
    public static let globalColor = UIColor(hex: "44A0B6")
    public static let background = UIColor(hex: "303040")
    public static let cellBackground = UIColor(hex: "393948")
    public static let inputBackground = UIColor(hex: "282832")
    public static let barTint = UIColor(hex: "343442")
    public static let textRed = UIColor(hex: "DC4D4D")
    public static let textGreen = UIColor(hex: "00DF86")
    public static let textTips = UIColor(hex: "73737D")
    public static let textAlpha = UIColor(hex: "FFFFFF", alpha: 0.5)
    public static let buttonGray = UIColor(hex: "7D8091")
    public static let buttonInvalid = UIColor(hex: "315968")
    public static let buttonInvalidText = UIColor(hex: "B7C5CA")
}

public struct NotificationNames {
    static let selectedTokenNotify = NSNotification.Name(rawValue:"SelectedTokenNotify")
    static let refreshDexAccountInfoNotify = NSNotification.Name(rawValue:"refreshDexAccountInfoNotify")
    static let refreshCurrency = NSNotification.Name(rawValue:"refreshCurrency")
    static let autorityPaySuccess = NSNotification.Name(rawValue:"autorityPaySuccess")
    static let getNetworking = NSNotification.Name(rawValue:"getNetworking")
    static let loseNetworking = NSNotification.Name(rawValue:"loseNetworking")
    static let websocketConnected = NSNotification.Name(rawValue:"websocketConnected")
    static let transactionsValueChanged = NSNotification.Name(rawValue:"transactionsValueChanged")
}

public struct UnitConfiguration {
    public static let gasPriceUnit: EthereumUnit = .gwei
    public static let gasFeeUnit: EthereumUnit = .ether
}


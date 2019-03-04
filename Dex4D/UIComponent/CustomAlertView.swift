//
//  CustomAlertView.swift
//  Dex4D
//
//  Created by zeng hai long on 15/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class CustomAlertView: UIView {
    
    struct SizeConstants {
        static let margin: CGFloat = 90
        static let top: CGFloat = 24
        static let bottomComponentHeight: CGFloat = 30
    }
    
    let titleText: String!
    
    let keyWindow: UIWindow!
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: "23232D")
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        label.textAlignment = .center
        label.text = titleText
        return label
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitleColor(UIColor(hex: "23232D"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.setTitle("OK", for: .normal)
        return button
    }()
    
    lazy var coverView: UIView = {
        let cover = UIView(frame: keyWindow.bounds)
        cover.backgroundColor = .black
        cover.alpha = 0.4
        return cover
    }()
    
    init(frame: CGRect, info: String, keyWindow: UIWindow) {
        self.titleText = info
        self.keyWindow = keyWindow
        super.init(frame: frame)
        keyWindow.addSubview(coverView)
        backgroundColor = .white
        layer.cornerRadius = 5.0
        layer.masksToBounds = true
        showAlert()
        confirmButton.addTarget(self, action: #selector(self.confirmAction), for: .touchUpInside)
    }
    
    private func showAlert() {
    
        let titleTextHeight = titleText.calcuateLabSizeHeight(font: UIFont.systemFont(ofSize: 16), maxWidth: Constants.ScreenWidth - 2 * SizeConstants.margin - 2 * Constants.leftPadding)
        self.size = CGSize(width: Constants.ScreenWidth - 2 * SizeConstants.margin, height: SizeConstants.bottomComponentHeight + 2 * SizeConstants.top + titleTextHeight)
        self.center = coverView.center
        keyWindow.addSubview(self)
        
        let titleView = UIView(frame: CGRect(x: 0, y: 0, width: self.width, height: self.height - SizeConstants.bottomComponentHeight))
        addSubview(titleView)
        
        titleView.addSubview(titleLabel)
        titleLabel.frame = titleView.bounds
        
        let bottomView = UIView(frame: CGRect(x: 0, y: self.height - SizeConstants.bottomComponentHeight, width: self.width, height: SizeConstants.bottomComponentHeight))
        addSubview(bottomView)
        bottomView.backgroundColor = UIColor(hex: "EEEEEE")
        bottomView.addSubview(confirmButton)
        confirmButton.frame = bottomView.bounds
        
    }
    
    @objc func confirmAction() {
        coverView.removeFromSuperview()
        removeFromSuperview()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

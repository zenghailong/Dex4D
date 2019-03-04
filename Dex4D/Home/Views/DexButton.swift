//
//  DexButton.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/16.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class DexButton: UIButton {

    var action: assetAction? = .none
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func commonInit() {
        self.titleLabel?.textAlignment = .center
        self.imageView?.contentMode = .scaleAspectFit
        self.titleLabel?.font = UIFont.defaultFont(size: 12)
        setTitleColor(.white, for: .normal)
        self.backgroundColor = UIColor(hex: "343442")
        self.layer.cornerRadius = 10
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        let titleX: CGFloat = 0
        let titleY = contentRect.size.height * 0.36
        let titleW = contentRect.size.width
        let titleH = contentRect.size.height - titleY
        return CGRect(x: titleX, y: titleY, width: titleW, height: titleH)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let imageW = contentRect.width
        let imageH = contentRect.size.height * 0.4
        return CGRect(x: 0, y: 12, width: imageW, height: imageH)
    }
}

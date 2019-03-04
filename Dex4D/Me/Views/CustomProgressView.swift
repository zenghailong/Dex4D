//
//  CustomProgressView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/25.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class CustomProgressView: UIView {
    
    var frontColor: UIColor = .blue {
        didSet {
            frontView.backgroundColor = frontColor
        }
    }
    
    var progress: CGFloat = 0 {
        didSet {
            progress = progress > 1 ? 1 : progress
            DispatchQueue.main.async {
                self.frontView.snp.updateConstraints { (make) in
                    make.width.equalTo(self.progress * self.frame.size.width)
                }
                self.needsUpdateConstraints()
                self.updateConstraintsIfNeeded()
                UIView.animate(withDuration: 0.2, animations: {
                    self.layoutIfNeeded()
                })
            }
        }
    }
    
    var frontView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 0, height: 6)
        view.backgroundColor = .blue
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        return view
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 6))
        self.backgroundColor = .gray
        self.layer.cornerRadius = 3
        self.layer.masksToBounds = true
        self.addSubview(frontView)
        frontView.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(0)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

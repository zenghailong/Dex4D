//
//  ScanResultViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/12.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class ScanResultViewController: BaseViewController {
    
    var resultString:String? {
        didSet {
            valueLabel.attributedText = resultString?.toAttributedString()
        }
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "The results of your scan are as follows：".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 12)
        label.textAlignment = .center
        label.alpha = 0.5
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "Scan result".localized
        
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: ScanViewController.self) == false
            }
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(150 + Constants.NavigationBarHeight)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        view.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
    }

}

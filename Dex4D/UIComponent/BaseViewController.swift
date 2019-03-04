//
//  BaseViewController.swift
//  TradingPlatform
//
//  Created by ColdChains on 2018/9/20.
//  Copyright © 2018 冰凉的枷锁. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {

    lazy var navigationBar: CustomNavigationBar = {
        let navigationBar = CustomNavigationBar(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: Constants.NavigationBarHeight))
        return navigationBar
    }()
 
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientLayer()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func createGradientLayer() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor(hex: "313140").cgColor, UIColor(hex: "22222C").cgColor]
        view.layer.addSublayer(gradientLayer)
    }
    
    func setCustomNavigationbar() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(Constants.NavigationBarHeight)
        }
    }
    
    func setBackButton() {
        navigationBar.setBackButton(target: self, action: #selector(self.backButtonAction))
    }
    
    @objc func backButtonAction() {
        navigationController?.popViewController(animated: true)
    }
    
}

//
//  WebViewNavigationBar.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol WebViewNavigationBarDelegate: class {
    func didSelectHomeButton()
    func didSelectCollectButton(sender: UIButton)
    func didSelectMenuButton()
}

class WebViewNavigationBar: UIView {
    
    weak var delegate: WebViewNavigationBarDelegate?
    
    private lazy var textFieldBackground: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.inputBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    lazy var urlTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = .white
        textField.placeholder = "请输入地址"
        textField.font = UIFont.defaultFont(size: 14)
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.setValue(Colors.textTips, forKeyPath: "_placeholderLabel.textColor")
        return textField
    }()
    
    private lazy var homeButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_home(), for: .normal)
        button.addTarget(self, action: #selector(self.homeButtonAction), for: .touchUpInside)
        return button
    }()
    
    private lazy var collectButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_collect(), for: .normal)
        button.setImage(R.image.icon_collect_select(), for: .selected)
        button.addTarget(self, action: #selector(self.collectButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_menu(), for: .normal)
        button.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
        return button
    }()
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: Constants.NavigationBarHeight))
        self.backgroundColor = Colors.cellBackground
        self.addSubview(homeButton)
        homeButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.bottom.equalToSuperview().offset(-7)
            make.width.height.equalTo(30)
        }
        self.addSubview(menuButton)
        menuButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-15)
            make.centerY.equalTo(homeButton)
            make.width.height.equalTo(homeButton)
        }
        self.addSubview(collectButton)
        collectButton.snp.makeConstraints { (make) in
            make.right.equalTo(menuButton.snp.left)
            make.centerY.equalTo(homeButton)
            make.width.height.equalTo(homeButton)
        }
        textFieldBackground.addSubview(urlTextField)
        urlTextField.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(15)
            make.right.equalToSuperview().offset(-5)
            make.top.bottom.equalToSuperview()
        }
        self.addSubview(textFieldBackground)
        textFieldBackground.snp.makeConstraints { (make) in
            make.centerY.equalTo(homeButton)
            make.left.equalTo(homeButton.snp.right).offset(5)
            make.right.equalTo(collectButton.snp.left).offset(-5)
            make.height.equalTo(30)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func homeButtonAction() {
        delegate?.didSelectHomeButton()
    }
    
    @objc private func collectButtonAction(sender: UIButton) {
        delegate?.didSelectCollectButton(sender: sender)
    }
    
    @objc private func menuButtonAction() {
        delegate?.didSelectMenuButton()
    }
    
    func setCollect(selected: Bool) {
        collectButton.isSelected = selected
    }

}

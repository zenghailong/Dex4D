//
//  CustomNavigationBar.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/13.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

private let Nav_Bar_Button_Width: CGFloat = 44
private let Nav_Bar_Button_Height: CGFloat = 44


final class CustomNavigationBar: UIView {
    
    var leftBarButton: UIButton = UIButton() {
        willSet{
            leftBarButton.removeFromSuperview()
        }
        didSet {
            contentView.addSubview(leftBarButton)
            leftBarButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.height.equalTo(Nav_Bar_Button_Height)
                if leftBarButton.imageView?.image == nil {
                    make.left.equalToSuperview().offset(15)
//                    make.right.lessThanOrEqualTo(titleView.snp.left).offset(-15)
                } else {
                    make.left.equalToSuperview().offset(4)
                    make.width.equalTo(Nav_Bar_Button_Width)
                }
            }
        }
    }
    
    var rightBarButton: UIButton = UIButton() {
        willSet{
            rightBarButton.removeFromSuperview()
        }
        didSet {
            contentView.addSubview(rightBarButton)
            rightBarButton.snp.makeConstraints { (make) in
                make.bottom.equalToSuperview()
                make.height.equalTo(Nav_Bar_Button_Height)
                if rightBarButton.imageView?.image == nil {
                    make.right.equalToSuperview().offset(-15)
//                    make.left.greaterThanOrEqualTo(titleView.snp.right).offset(15)
                } else {
                    make.right.equalToSuperview().offset(-4)
                    make.width.equalTo(Nav_Bar_Button_Width)
                }
            }
        }
    }
    
    let contentView: UIView = {
        let contentView = UIView()
        contentView.backgroundColor = .clear
        return contentView
    }()
    
    var titleView: UIView = UIView() {
        willSet{
            titleView.removeFromSuperview()
        }
        didSet {
            contentView.addSubview(titleView)
            titleView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalToSuperview().offset(-10)
                if titleView.frame.size.width > 0 {
                    make.width.equalTo(titleView.frame.size.width)
                } else {
                    make.width.equalToSuperview().offset(-30 - Nav_Bar_Button_Width * 2)
                }
            }
        }
    }
    
    var titleText: String? {
        didSet {
            let titleLabel = UILabel()
            titleLabel.backgroundColor = UIColor.clear
            titleLabel.textColor = .white
            titleLabel.textAlignment = .center
            titleLabel.font = UIFont.defaultFont(size: 16)
            titleLabel.text = titleText ?? ""
            titleView = titleLabel
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview().inset(UIEdgeInsetsMake(Constants.StatusBarHeight, 0, 0, 0))
        }
    }
    
    public func setBackButton(target: Any?, action: Selector) {
        setLeftButtonImage(image: R.image.icon_back(), target: target, action: action)
    }
    
    public func setLeftButtonTitle(title: String, target: Any?, action: Selector) -> UIButton {
        self.leftBarButton = setNavBarButtonTitle(title: title, image: nil, target: target, action: action)
        return leftBarButton
    }
    @discardableResult
    public func setRightButtonTitle(title: String, target: Any?, action: Selector) -> UIButton {
        self.rightBarButton = setNavBarButtonTitle(title: title, image: nil, target: target, action: action)
        return rightBarButton
    }
    @discardableResult
    public func setLeftButtonImage(image: UIImage?, target: Any?, action: Selector) -> UIButton {
        self.leftBarButton = setNavBarButtonTitle(title: "", image: image, target: target, action: action)
        return leftBarButton
    }
    
    public func setRightButtonImage(image: UIImage?, target: Any?, action: Selector) -> UIButton {
        self.rightBarButton = setNavBarButtonTitle(title: "", image: image, target: target, action: action)
        return rightBarButton
    }
    
    private func setNavBarButtonTitle(title: String, image: UIImage?, target: Any?, action: Selector) -> UIButton {
        let navBarButton = self.navBarButton()
        navBarButton.setTitle(title, for: .normal)
        navBarButton.setImage(image, for: .normal)
        navBarButton.addTarget(target, action: action, for: .touchUpInside)
        self.contentView.addSubview(navBarButton)
        return navBarButton
    }
    
    private func navBarButton() -> UIButton {
        let navBarButton = UIButton(type: .custom)
        navBarButton.setTitleColor(UIColor.white, for: .normal)
        navBarButton.titleLabel?.font = UIFont.defaultFont(size: 14)
        return navBarButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

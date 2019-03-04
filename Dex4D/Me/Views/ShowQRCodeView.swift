//
//  ShowQRCodeView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/5.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol ShowQRCodeViewDelegate: class {
    func copyLink(text: String)
    func saveImage(image: UIImage)
    func showSaveAlert(image: UIImage)
    func setAmount()
}

class ShowQRCodeView: UIView {
    
    weak var delegate: ShowQRCodeViewDelegate?
    
    let viewModel: ShowQRCodeViewModel
    
    private lazy var codeImageView: UIImageView = {
        let imageView = UIImageView()
        
        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: #selector(showSaveAlert))
        longpressGesutre.minimumPressDuration = 0.5
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(longpressGesutre)
        return imageView
    }()
    
    private lazy var amountButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(viewModel.amountButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(setAmount), for: .touchUpInside)
        return button
    }()
    
    private lazy var saveButton: UIButton = {
        let button = UIButton(type: .custom)
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.setTitle(viewModel.saveButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
//        button.addTarget(self, action: #selector(saveImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private lazy var copyButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = Colors.globalColor
        button.setTitle(viewModel.copyButtonText, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(copyLink), for: .touchUpInside)
        return button
    }()
    
    init(address: String, showType: ShowQRCodeType) {
        self.viewModel = ShowQRCodeViewModel(address: address, showType: showType)
        super.init(frame: CGRect())
        initSubViews(showType: showType)
        viewModel.delegate = self
        viewModel.setDefaultValue()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initSubViews(showType: ShowQRCodeType) {
        self.addSubview(codeImageView)
        codeImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalTo(viewModel.imageSize)
        }
        
//        if showType == .wallet {
//            self.addSubview(amountButton)
//            amountButton.snp.makeConstraints { (make) in
//                make.top.equalTo(codeImageView.snp.bottom).offset(15)
//                make.right.equalTo(self.snp.centerX).offset(-15)
//            }
//            self.addSubview(saveButton)
//            saveButton.snp.makeConstraints { (make) in
//                make.top.equalTo(codeImageView.snp.bottom).offset(15)
//                make.left.equalTo(self.snp.centerX).offset(15)
//            }
//        } else {
            self.addSubview(saveButton)
            saveButton.snp.makeConstraints { (make) in
                make.top.equalTo(codeImageView.snp.bottom).offset(18)
                make.centerX.equalToSuperview()
            }
//        }
        
        self.addSubview(linkLabel)
        linkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(saveButton.snp.bottom).offset(18)
            make.left.equalToSuperview().offset(84)
            make.right.equalToSuperview().offset(-84)
        }
        
        self.addSubview(copyButton)
        copyButton.snp.makeConstraints { (make) in
            make.top.equalTo(linkLabel.snp.bottom).offset(50)
            make.left.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-30)
            make.height.equalTo(40)
        }
        
    }
    
    private func createImage(message: String, amount: Double = 0) {
        linkLabel.text = viewModel.linkLabelText
//        codeImageView.image = UIImage.createQRCodeImage(content: message + "???" + amount.stringValue(), size: viewModel.imageSize)
        codeImageView.image = UIImage.createQRCodeImage(content: message, size: viewModel.imageSize)
    }
    
    @objc private func showSaveAlert() {
        if let image = codeImageView.image {
            delegate?.showSaveAlert(image: image)
        }
    }
    
    @objc private func copyLink() {
        if let text = linkLabel.text {
            delegate?.copyLink(text: text)
        }
    }
    
    @objc private func saveImage() {
        if let image = codeImageView.image {
            delegate?.saveImage(image: image)
        }
    }
    
    @objc private func setAmount() {
        delegate?.setAmount()
    }
}


extension ShowQRCodeView: ShowQRCodeViewModelDelegate {
    func linkLabelTextValueChanged() {
        createImage(message: viewModel.linkLabelText, amount: viewModel.amount)
    }
}

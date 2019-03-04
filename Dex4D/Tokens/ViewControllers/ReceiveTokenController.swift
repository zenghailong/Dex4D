//
//  ReceiveTokenController.swift
//  Dex4D
//
//  Created by zeng hai long on 17/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import MBProgressHUD

class ReceiveTokenController: BaseViewController {
    
    let viewModel: ReceiveTokenViewModel
    
    lazy var qrImageView: UIImageView = {
        let qrImageView = UIImageView(image: viewModel.qrImage)
        qrImageView.isUserInteractionEnabled = true
        let longpressGesutre = UILongPressGestureRecognizer(target: self, action: #selector(showSaveAlert))
        longpressGesutre.minimumPressDuration = 1
        qrImageView.addGestureRecognizer(longpressGesutre)
        return qrImageView
    }()
    
    lazy var addressLabel: UILabel = {
        let addressLabel = UILabel()
        addressLabel.textColor = .white
        addressLabel.text = viewModel.wallet.address.description
        addressLabel.numberOfLines = 2
        addressLabel.textAlignment = .center
        addressLabel.font = UIFont.defaultFont(size: 16)
        return addressLabel
    }()
    
    lazy var copyButton: UIButton = {
        let copyButton = UIButton(type: .custom)
        copyButton.setTitle(viewModel.buttonTitleText, for: .normal)
        copyButton.setTitleColor(.white, for: .normal)
        copyButton.titleLabel?.font = UIFont.defaultFont(size: 16)
        copyButton.backgroundColor = Colors.globalColor
        copyButton.layer.cornerRadius = Constants.BaseButtonHeight * 0.5
        copyButton.layer.masksToBounds = true
        copyButton.addTarget(self, action: #selector(self.copyAddress(_:)), for: .touchUpInside)
        return copyButton
    }()
    
    init(viewModel: ReceiveTokenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.titleText
        
        let stackView = UIStackView(
            arrangedSubviews: [
                qrImageView,
                addressLabel,
                copyButton
        ]) 
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(128)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(320)
        }
        NSLayoutConstraint.activate([
            qrImageView.heightAnchor.constraint(equalToConstant: viewModel.qrImage.size.height),
            copyButton.heightAnchor.constraint(equalToConstant: Constants.BaseButtonHeight),
            addressLabel.leadingAnchor.constraint(equalTo: copyButton.leadingAnchor, constant: 20),
        ])
    }
    
    @objc func copyAddress(_ sender: UIButton) {
        UIPasteboard.general.string = viewModel.wallet.address.description
        showTipsMessage(message: "Copied".localized)
    }
    
    
    @objc private func showSaveAlert() {
        let alertController = UIAlertController (
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let action1 = UIAlertAction(
            title: "Save to photo Librany".localized,
            style: .default
        ) { [weak self] _ in
            self?.saveToPhotoLibrary()
        }
//        let action2 = UIAlertAction(
//            title: "Share QR Code".localized,
//            style: .default
//        ) { [weak self] _ in
//            self?.shareQRCode()
//        }
        let cancelAction = UIAlertAction(
            title: "Cancel".localized,
            style: .cancel
        )
        alertController.addAction(action1)
//        alertController.addAction(action2)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveToPhotoLibrary() {
        if let image = qrImageView.image {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didSaveImage(image:didFinishSavingWithError:contextInfo:)), nil)
            showTipsMessage(message: "Saved".localized)
        }
    }
    
    @objc private func didSaveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        print("save over")
    }
    
    private func shareQRCode() {
        
    }
    
}

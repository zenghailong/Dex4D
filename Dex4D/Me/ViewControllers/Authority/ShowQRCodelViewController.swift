//
//  ReferralViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

enum ShowQRCodeType {
    case wallet
    case referral
}

class ShowQRCodeViewController: BaseViewController {
    
    var qrcodeView: ShowQRCodeView
    var showType: ShowQRCodeType
    
    init(address: String, showType: ShowQRCodeType = .wallet) {
        self.showType = showType
        qrcodeView = ShowQRCodeView(address: address, showType: showType)
        super.init(nibName: nil, bundle: nil)
        qrcodeView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = showType == .referral ? "Referral code".localized : "Receive".localized
        
        view.addSubview(qrcodeView)
        qrcodeView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(130 * Constants.ScaleHeight)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    
    private func saveToPhotoLibrary(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.didSaveImage(image:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func didSaveImage(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: AnyObject) {
        if error == nil {
            showTipsMessage(message: "Saved".localized)
        } else {
            let message = "Please go -> [Settings-privacy-Photos-Dex4D] opens photos privileges".localized
            UIAlertController.alertAction(target: self, title: "Unable to save image".localized, message: message, cancelActionText: "OK".localized)
        }
    }
    
    private func shareQRCode() {
        
    }

}

extension ShowQRCodeViewController: ShowQRCodeViewDelegate {
    func copyLink(text: String) {
        UIPasteboard.general.string = text
        showTipsMessage(message: "Copied".localized)
    }
    func saveImage(image: UIImage) {
        saveToPhotoLibrary(image: image)
    }
    func showSaveAlert(image: UIImage) {
        let alertController = UIAlertController (
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        let action1 = UIAlertAction(
            title: "Save to photo Librany".localized,
            style: .default
        ) { [weak self] _ in
            self?.saveToPhotoLibrary(image: image)
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
    func setAmount() {
        var inputText: UITextField = UITextField();
        let alert = UIAlertController.init(title: "Input amount".localized, message: nil, preferredStyle: .alert)
        let ok = UIAlertAction.init(title: "确定", style:.default) { (action:UIAlertAction) ->() in
            if let text = inputText.text, text.isAmountString() {
                self.qrcodeView.viewModel.amount = text.doubleValue
            } else {
                self.showTipsMessage(message: "金额无效")
            }
        }
        let cancel = UIAlertAction.init(title: "取消", style:.cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        alert.addTextField { (textField) in
            inputText = textField
            inputText.textAlignment = .center
            if self.qrcodeView.viewModel.amount != 0 {
                inputText.text = self.qrcodeView.viewModel.amount.stringValue()
            }
        }
        self.present(alert, animated: true, completion: nil)
    }
}

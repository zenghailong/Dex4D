//
//  ScanViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/12.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import SGQRCode
import AVFoundation

protocol ScanViewControllerDelegate: class {
    func didScanQRCode(result: String)
}

class ScanViewController: BaseViewController {
    
    weak var delegate: ScanViewControllerDelegate?
    
    private lazy var scanManager: SGQRCodeScanManager = {
        let manager = SGQRCodeScanManager.shared() ?? SGQRCodeScanManager()
        let arr = [AVMetadataObject.ObjectType.qr, AVMetadataObject.ObjectType.ean13, AVMetadataObject.ObjectType.ean8, AVMetadataObject.ObjectType.code128];
        manager.setupSessionPreset(AVCaptureSession.Preset.hd1920x1080.rawValue, metadataObjectTypes: arr, currentController: self)
        manager.resetSampleBufferDelegate()
        manager.delegate = self
        return manager
    }()
    
    private lazy var scanView: SGQRCodeScanningView = {
        let view = SGQRCodeScanningView()
        view.scanningImageName = "scan_image"
        view.scanningAnimationStyle = ScanningAnimationStyleGrid
        view.cornerColor = Colors.globalColor
        view.borderColor = Colors.globalColor
        view.backgroundAlpha = 0.5
        view.cornerWidth = 4
        return view
    }()
    
    lazy var activityIndicatorView: UIActivityIndicatorView = {
        let active = UIActivityIndicatorView.init(activityIndicatorStyle:.whiteLarge)
        active.hidesWhenStopped = true
        return active
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "The QRCode can be automatically scanned in the box.".localized
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var flashlightButton: UIButton = {
        let button = UIButton()
        button.setImage(R.image.icon_flashlight_close(), for: .normal)
        button.setImage(R.image.icon_flashlight_open(), for: .selected)
        button.addTarget(self, action: #selector(self.flashlightButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        _ = navigationBar.setRightButtonTitle(title: "Photos".localized, target: self, action: #selector(self.rightAction))
        navigationBar.backgroundColor = Colors.background
        
        view.addSubview(scanView)
        scanView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { (make) in
            make.center.equalTo(scanView)
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0.77 * self.view.frame.size.height)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        
        view.addSubview(flashlightButton)
        flashlightButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(0.67 * self.view.frame.size.height)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(30)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        scanView.removeTimer()
        scanView.addTimer()
        scanManager.startRunning()
        view.removeGradientLayer()
        activityIndicatorView.stopAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SGQRCodeHelperTool.sg_CloseFlashlight()
        flashlightButton.isSelected = false
        scanView.removeTimer()
        scanManager.stopRunning()
    }
    
    @objc private func flashlightButtonAction(sender: UIButton) {
        if sender.isSelected {
            SGQRCodeHelperTool.sg_CloseFlashlight()
        } else {
            SGQRCodeHelperTool.sg_openFlashlight()
        }
        sender.isSelected = !sender.isSelected
    }
    
    @objc private func rightAction() {
        if let manager = SGQRCodeAlbumManager.shared() {
            manager.readQRCodeFromAlbum(withCurrentController: self)
            manager.delegate = self
            if manager.isPHAuthorization {
                scanView.removeTimer()
            }
        }
    }
    
    private func putScanResult(result: String) {
        activityIndicatorView.startAnimating()
        scanManager.stopRunning()
        scanView.removeTimer()
        scanManager.playSoundName("sound.caf")
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        delegate?.didScanQRCode(result: result)
    }

}

extension ScanViewController: SGQRCodeScanManagerDelegate {
    func qrCodeScanManager(_ scanManager: SGQRCodeScanManager!, brightnessValue: CGFloat) {
        
    }
    func qrCodeScanManager(_ scanManager: SGQRCodeScanManager!, didOutputMetadataObjects metadataObjects: [Any]!) {
        if metadataObjects.count > 0 {
            scanManager.stopRunning()
            let result = metadataObjects[0] as? AVMetadataMachineReadableCodeObject
            if let str = result?.stringValue {
                putScanResult(result: str)
            } else {
                print("未识别的二维码")
            }
        } else {
            print("未识别的二维码")
        }
    }
}

extension ScanViewController: SGQRCodeAlbumManagerDelegate {
    func qrCodeAlbumManager(_ albumManager: SGQRCodeAlbumManager!, didFinishPickingMediaWithResult result: String!) {
        putScanResult(result: result)
    }
    func qrCodeAlbumManagerDidReadQRCodeFailure(_ albumManager: SGQRCodeAlbumManager!) {
        print("未识别的二维码")
    }
    func qrCodeAlbumManagerDidCancel(withImagePickerController albumManager: SGQRCodeAlbumManager!) {
        print("取消")
    }
}

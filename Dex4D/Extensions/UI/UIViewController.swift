//
//  UIViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import MBProgressHUD
import AVFoundation

extension UIViewController {
    
    func displayLoading(
        text: String = "",
        animated: Bool = true
    ) {
        let hud = MBProgressHUD.showAdded(to: self.view, animated: animated)
        hud.label.text = text
    }
    
    func hideLoading(animated: Bool = true) {
        MBProgressHUD.hide(for: view, animated: animated)
    }
    
    func displayError(error: Error) {
        let alertController = UIAlertController(title: error.localizedDescription, message: "", preferredStyle: UIAlertControllerStyle.alert)
        alertController.popoverPresentationController?.sourceView = self.view
        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    func showShareActivity(from sender: UIView, with items: [Any], completion: (() -> Swift.Void)? = nil) {
        let activityViewController = UIActivityViewController.make(items: items)
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = sender.centerRect
        present(activityViewController, animated: true, completion: completion)
    }
    
    func showTipsMessage(message: String?) {
        Toast.showMessage(message: message)
    }
    
    func alertErrorMessage(message: String?) {
        guard let str = message else {
            return
        }
        let alertController = UIAlertController(title: "Error", message: str, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            print("ok")
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func alertMessage(title: String?, message: String?, ok: String, completion: (() -> Void)?) {
        if title == nil && message == nil {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in
            completion?()
        }))
        present(alertController, animated: true, completion: nil)
    }
    
    func alertMessageWithCancel(title: String?, message: String?, ok: String, cancel: String, completion: (() -> Void)?) {
        if title == nil && message == nil {
            return
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: ok, style: .default, handler: { _ in
            completion?()
        }))
        alertController.addAction(UIAlertAction(title: cancel, style: .default, handler: { _ in
            print("cancel")
        }))
        present(alertController, animated: true, completion: nil)
    }

}

extension UIActivityViewController {
    static func make(items: [Any]) -> UIActivityViewController {
        return UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
}

extension UIViewController {
    func swiftClassFromString(className: String?) -> UIViewController? {
        if className == nil {
            return nil
        }
        if  let appName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String? {
            let classStringName = "\(appName).\(className!)"
            let classType = NSClassFromString(classStringName) as? UIViewController.Type
            if let type = classType {
                let newVC = type.init()
                return newVC
            }
        }
        return nil;
    }
}

extension UIViewController {
    func pushToScan(navigationController: UINavigationController?, push viewController: UIViewController) {
        if let _ = AVCaptureDevice.default(for: .video) {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            switch status {
            case .authorized:
                navigationController?.pushViewController(viewController, animated: true)
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video) { (granted) in
                    if granted {
                        DispatchQueue.main.async {
                            navigationController?.pushViewController(viewController, animated: true)
                        }
                    } else {
                        UIAlertController.alertAction(target: self, title: "Unable to open camera".localized, message: nil, cancelActionText: "OK".localized)
                    }
                }
            case .denied:
                let message = "Please go -> [Settings-privacy-camera-Dex4D] opens camera privileges".localized
                UIAlertController.alertAction(target: self, title: "Unable to open camera".localized, message: message, cancelActionText: "OK".localized)
            case .restricted:
                UIAlertController.alertAction(target: self, title: "Unable to open camera".localized, message: nil, cancelActionText: "OK".localized)
            default:
                break
            }
        } else {
            UIAlertController.alertAction(target: self, title: "Camera not detected".localized, message: nil, cancelActionText: "OK".localized)
        }
    }
}

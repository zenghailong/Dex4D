//
//  FingerPrintUnlockViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/30.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class FingerPrintUnlockViewController: BaseViewController {

    private lazy var launchScreenView: LaunchScreenView = {
        return LaunchScreenView()
    }()
    
    private lazy var fingerPrintButton: UIButton = {
        let button = UIButton.init()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("轻触唤起指纹解锁", for: .normal)
        button.setTitleColor(.gray, for: .normal)
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.fingerPrintUnlock))
        button.addGestureRecognizer(tap)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        navigationBar.titleText = "指纹解锁"
        
        view.addSubview(launchScreenView)
        launchScreenView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        view.addSubview(fingerPrintButton)
        fingerPrintButton.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        fingerPrintUnlock()
    }
    
    @objc func fingerPrintUnlock() {
        TouchIdManager.startFingerUnlock(withtips:"指纹登录") { (result:TouchIdManager.TouchIdResult) in
            switch result{
            case .success:
                DispatchQueue.main.async {
                    UserDefaults.setBoolValue(value: true, key: Dex4DKeys.touchIdUnlock)
                    self.dismiss(animated: true, completion: nil)
                }
                break
            case .failed:
                break
            case .inputPassword:
                break
            case .touchidNotAvailable:
                break
            default:
                break
            }
        }
    }

}

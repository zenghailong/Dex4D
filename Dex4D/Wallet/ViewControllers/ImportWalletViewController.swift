//
//  ImportWalletViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/28.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit


protocol ImportWalletViewControllerDelegate: class {
    // func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportWalletViewController)
    func importWallet(with importSelectType: ImportSelectionType, viewController: ImportWalletViewController)
    func didCancelImportWallet(in viewController: ImportWalletViewController)
}

final class ImportWalletViewController: BaseViewController {
    
    lazy var importKeystoreView: SelectImportView = {
        let importKeystoreView = R.nib.selectImportView.firstView(owner: nil, options: nil)
        importKeystoreView?.titleText = "Import with keystore".localized
        importKeystoreView?.importSelectType = .keystore
        return importKeystoreView ?? SelectImportView()
    }()
    
    lazy var importMemoricView: SelectImportView = {
        let importWordsView = R.nib.selectImportView.firstView(owner: nil, options: nil)
        importWordsView?.importSelectType = .mnemonic
        importWordsView?.titleText = "Import with memoric".localized
        return importWordsView ?? SelectImportView()
    }()
    
    weak var delegate: ImportWalletViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        navigationBar.titleText = "Restore".localized
        setBackButton()
        
        let stackView = UIStackView(arrangedSubviews: [
            importKeystoreView,
            importMemoricView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 10
        view.addSubview(stackView)
        stackView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.height.equalTo(116)
            make.centerX.equalToSuperview()
        }
        
        importKeystoreView.selectImportStyleBlock = {[weak self] importStyle in
            guard let `self` = self else { return }
            self.delegate?.importWallet(with: importStyle, viewController: self)
        }
        
        importMemoricView.selectImportStyleBlock = {[weak self] importStyle in
            guard let `self` = self else { return}
            self.delegate?.importWallet(with: importStyle, viewController: self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewControllers = navigationController?.viewControllers {        
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: GenerateEnterPasswordController.self) == false
            }
        }
    }
    
    deinit {
        self.delegate?.didCancelImportWallet(in: self)
    }
}

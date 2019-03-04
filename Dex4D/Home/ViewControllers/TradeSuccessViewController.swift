//
//  WithDrawSuccessViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt

protocol TradeSuccessViewControllerDelegate: class {
    func didPressDone(in viewController: UIViewController, type: D4DTransferActionType)
}

class TradeSuccessViewController: BaseViewController {
    
    weak var delegate: TradeSuccessViewControllerDelegate?
    
    let txHash: String
    let configurator: DexTransactionConfigurator
    let viewModel: DexConfirmViewModel

    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.withdraw_success()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.titleText
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var valueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 18)
        label.textAlignment = .center
        label.text = viewModel.amountText
        return label
    }()
    
    private lazy var pendingLabel: UILabel = {
        let label = UILabel()
        label.text = "Pending".localized
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .center
        return label
    }()
    
    private lazy var fromTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "From".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var fromValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.from
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    private lazy var toTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "To".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    private lazy var toValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.text = viewModel.to
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var gasTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Actual Tx Cost/Fee".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var gasValueLabel: UILabel = {
        let label = UILabel()
        label.text = viewModel.gas
        label.textColor = Colors.textTips
        label.font = UIFont.defaultFont(size: 14)
        label.textAlignment = .right
        return label
    }()
    
    private lazy var txsTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "TxsHash".localized
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var txsValueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(viewModel.getTxHashValue(txHash: txHash), for: .normal)
        button.setTitleColor(Colors.globalColor, for: .normal)
        button.titleLabel?.font = UIFont.defaultFont(size: 14)
        button.addTarget(self, action: #selector(self.txsButtonAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    init(
        configurator: DexTransactionConfigurator,
        txHash: String
    ) {
        self.txHash = txHash
        self.configurator = configurator
        self.viewModel = DexConfirmViewModel(configurator: configurator)
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        _ = navigationBar.setRightButtonTitle(title: "Done".localized, target: self, action: #selector(self.backAction))
        initSubViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let viewControllers = navigationController?.viewControllers {
            navigationController?.viewControllers = viewControllers.filter {
                $0.isKind(of: TradeViewController.self) == false &&
                    $0.isKind(of: WithDrawViewController.self) == false &&
                    $0.isKind(of: NickNameViewController.self) == false
            }
        }
    }
    
    override func viewWillDisappear(_ animated:Bool) {
        super.viewWillDisappear(animated)
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated:Bool) {
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    @objc private func backAction() {
        self.navigationController?.popViewController(animated: true)
        delegate?.didPressDone(in: self, type: configurator.type)
    }
    
    
    private func initSubViews() {
        view.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight + 44)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(iconImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        view.addSubview(valueLabel)
        valueLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        view.addSubview(pendingLabel)
        pendingLabel.snp.makeConstraints { (make) in
            make.top.equalTo(valueLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let line = UIView()
        line.backgroundColor = UIColor(hex: "383847")
        view.addSubview(line)
        line.snp.makeConstraints { (make) in
            make.top.equalTo(pendingLabel.snp.bottom).offset(30 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        view.addSubview(fromTitleLabel)
        fromTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(line.snp.bottom).offset(Constants.leftPadding)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(fromValueLabel)
        fromValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(fromTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        view.addSubview(toTitleLabel)
        toTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fromTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(toValueLabel)
        toValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(toTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        view.addSubview(gasTitleLabel)
        gasTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(toTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        view.addSubview(gasValueLabel)
        gasValueLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(gasTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
        
        view.addSubview(txsTitleLabel)
        txsTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(gasTitleLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(Constants.leftPadding)
        }
        
        view.addSubview(txsValueButton)
        txsValueButton.snp.makeConstraints { (make) in
            make.centerY.equalTo(txsTitleLabel)
            make.right.equalToSuperview().offset(-Constants.leftPadding)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func txsButtonAction(sender: UIButton) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator {
            print(Dex4DUrls.hash + txHash)
            main.browserCoordinator.rootViewController.urlString = Dex4DUrls.hash + txHash
            main.tabBarController.selectedIndex = 2
            navigationController?.popToRootViewController(animated: false)
        }
    }
}

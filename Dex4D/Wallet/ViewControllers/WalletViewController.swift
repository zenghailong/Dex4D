//
//  WalletViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/9/29.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import RealmSwift

protocol WalletViewControllerDelegate: class {

    func didSelectReceive(account: Account, in viewController: UIViewController)
    func didSelectSend(in viewController: UIViewController)
    func didCheckHistory(in viewController: UIViewController)
}

class WalletViewController: BaseViewController {
    
    weak var delegate: WalletViewControllerDelegate?
    
    fileprivate var viewModel: TokensViewModel
    
    let account: Account
    
    let timer = TimerHelper.shared
    
    private lazy var assetView: WalletAssetView = {
        let assetView = R.nib.walletAssetView.firstView(owner: nil, options: nil)
        assetView?.delegate = self
        return assetView ?? WalletAssetView()
    }()
    
    private lazy var assetTitleView: AssetTitleView = {
        let assetView = R.nib.assetTitleView.firstView(owner: nil, options: nil)
        return assetView ?? AssetTitleView()
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(R.nib.assetViewCell(), forCellReuseIdentifier: R.nib.assetViewCell.name)
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    init(viewModel: TokensViewModel) {
        self.viewModel = viewModel
        self.account = viewModel.session.account.accounts.first!
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.resignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(WalletViewController.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startTokenObservation()
        setCustomNavigationbar()
        navigationBar.titleText = account.address.description.addressTitleString()
        setupUI()
        timer.scheduledDispatchTimer(WithTimerName: Config.walletBalanceTimer, timeInterval: 10, queue: .main, repeats: true) {[weak self] in
            self?.viewModel.fetch()
        }
        assetView.setTotalAsset()
//        NotificationCenter.default.addObserver(self, selector: #selector(notificationAction), name: Notifications.refreshCurrency, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    @objc private func notificationAction(notify: Notification) {
        assetView.setTotalAsset()
    }
    
    private func startTokenObservation() {
        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            let tableView = strongSelf.tableView
            switch changes {
            case .initial:
               tableView.reloadData()
            case .update:
                tableView.reloadData()
            case .error: break
            }
            if let _ = self?.viewModel.store.tokensPrice {
                self?.viewModel.setTotalAsset()
            }
        }
    }
    
    @objc func resignActive() {
        stopTokenObservation()
    }
    
    @objc func didBecomeActive() {
        viewModel.fetch()
        startTokenObservation()
    }
    
    private func stopTokenObservation() {
        viewModel.invalidateTokensObservation()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        timer.cancleTimer(WithTimerName: Config.walletBalanceTimer)
        resignActive()
        stopTokenObservation()
    }
    
    private func setupUI() {
        view.addSubview(assetView)
        assetView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(110 + Constants.ScreenWidth / 3)
        }
        
        view.addSubview(assetTitleView)
        assetTitleView.snp.makeConstraints { (make) in
            make.top.equalTo(assetView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(assetTitleView.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-Constants.BottomBarHeight)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.store.tokens.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.assetViewCell.name) as! AssetViewCell
        cell.cover.isEnabled = false
        cell.configCell(hide: assetView.isHideAsset, token: viewModel.store.tokens[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
}

extension WalletViewController: WalletAssetViewDelegate {
    func didPressedActionButton(type: assetAction, in assetView: WalletAssetView) {
        switch type {
        case .receive:
            delegate?.didSelectReceive(account: account, in: self)
        case .send:
            delegate?.didSelectSend(in: self)
        case .viewHistory:
            delegate?.didCheckHistory(in: self)
        }
    }
    func didSelectSwitch() {
        tableView.reloadData()
    }
}

extension WalletViewController: TokensViewModelDelegate {
    func refreshTokens() {
        tableView.reloadData()
    }
    func refreshTotalBalance(value: String) {
        assetView.setTotalAsset(value: value)
    }
}

extension WalletViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off_y = scrollView.contentOffset.y
        if off_y < 0 {
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}

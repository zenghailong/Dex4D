//
//  HomeViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import RealmSwift

protocol HomeViewControllerDelegate: class {
    func didPressHeaderView(for viewModel: DexAccountViewModel, viewController: UIViewController)
    func didPressedScan(in viewController: UIViewController)
    func didSelectedTradeOperation(for pool: DexPool, viewModel: DexAccountViewModel, viewController: UIViewController)
}

class HomeViewController: BaseViewController {
    
    weak var delegate: HomeViewControllerDelegate?
    
    let account: WalletInfo
    let session: WalletSession
    let config: DexConfig
    let dexTokenStorage: DexTokenStorage
    let dexTransactionStore: DexTransactionsStorage
    
    var notificationToken: NotificationToken?
    
    lazy var viewModel: DexAccountViewModel = {
        let viewModel = DexAccountViewModel(
            account: account,
            dexTokenStorage: dexTokenStorage,
            config: config,
            dexTransactionStore: dexTransactionStore
        )
        viewModel.delegate = self
        return viewModel
    }()
    
    private lazy var headerView: HomeHeaderView = {
        let view = HomeHeaderView(
            frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: 212),
            config: config,
            transactionStore: dexTransactionStore
        )
        view.delegate = self
        return view
    }()
    
    let sectionView = HomeSectionHeaderView()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HomeTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(HomeTableViewCell.self))
        return tableView
    }()
    
    init(
        session: WalletSession,
        dexTokenStorage: DexTokenStorage,
        config: DexConfig,
        dexTransactionStore: DexTransactionsStorage
    ) {
        self.session = session
        self.account = session.account
        self.dexTokenStorage = dexTokenStorage
        self.config = config
        self.dexTransactionStore = dexTransactionStore
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        navigationBar.titleText = viewModel.titleText
        _ = navigationBar.setRightButtonImage(image: R.image.icon_scan(), target: self, action: #selector(self.scanAction))
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(headerView.bounds.size.height)
        }
        
        view.addSubview(sectionView)
        sectionView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(sectionView.bounds.size.height)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(sectionView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        notificationToken = dexTokenStorage.marketcapObjects.observe{ [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial, .update:
                self?.tableView.reloadData()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    @objc private func scanAction() {
        delegate?.didPressedScan(in: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dexTokenStorage.marketcapObjects.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(HomeTableViewCell.self)) as! HomeTableViewCell
        let marketcapObject = dexTokenStorage.marketcapObjects[indexPath.row]
        let tokenObject = viewModel.tokenObjects.filter { $0.name == marketcapObject.symbol }.first
        if let tokenObject = tokenObject {
            cell.configCell(With: marketcapObject, token: tokenObject)
        } else {
            var token = DexTokenObject()
            token.name = marketcapObject.symbol
            token.state = 4
            cell.configCell(With: marketcapObject, token: token)
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        if let pool = viewModel.pools?[indexPath.row] {
//            delegate?.didSelectedTradeOperation(for: pool, viewModel: viewModel, viewController: self)
//        }
    }
}

extension HomeViewController: DexAccountViewModelDelegate {
    func refresh() {
        headerView.refreshHeaderView(viewModel)
    }
    func transactionsValueChanged() {
        headerView.setPeddingLabelText()
    }
    func transactionFailed(hashArray: [String]) {
        let message = String(format: "%d Dex4D failed transaction happened. Click for more information".localized, hashArray.count)
        if hashArray.count == 1 {
            let hash = hashArray[0]
            alertMessageWithCancel(title: "Transaction failed".localized, message: message, ok: "See".localized, cancel: "Cancel".localized) {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator {
                    print(Dex4DUrls.hash + hash)
                    main.browserCoordinator.rootViewController.urlString = Dex4DUrls.hash + hash
                    main.tabBarController.selectedIndex = 2
                    self.navigationController?.popToRootViewController(animated: false)
                }
            }
        } else if hashArray.count > 1 {
            alertMessageWithCancel(title: String(format: "Transaction failed".localized, hashArray.count), message: message, ok: "See".localized, cancel: "Cancel".localized) {
                guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                guard let main = appDelegate.coordinator.coordinators.first as? MainCoordinator else { return }
                let index = main.tabBarController.selectedIndex
                guard let nvc = main.tabBarController.viewControllers?[index] as? UINavigationController else { return }
                let controller = TransactionsViewController(dexTransactionStore: self.viewModel.dexTransactionStore)
                nvc.pushViewController(controller, animated: true)
            }
        }
    }
}

extension HomeViewController: HomeHeaderViewDelegate {
    func didSelectContainerView() {
        delegate?.didPressHeaderView(for: viewModel, viewController: self)
    }
}

extension HomeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off_y = scrollView.contentOffset.y
        if off_y < 0 {
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}

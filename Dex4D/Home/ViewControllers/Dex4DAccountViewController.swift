//
//  Dex4DAccountViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/28.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import RealmSwift

protocol Dex4DAccountViewControllerDelegate: class {
    func didSelectedTradeOperation(for pool: DexPool, viewModel: DexAccountViewModel, viewController: UIViewController)
    func didPressedWithdraw(for viewModel: DexAccountViewModel, viewController: UIViewController)
    func checkoutTransaction(in viewController: UIViewController)
}

class Dex4DAccountViewController: BaseViewController {
    
    weak var delegate: Dex4DAccountViewControllerDelegate?
    
    let keystore: Keystore
    let account: WalletInfo
    let viewModel: DexAccountViewModel
    let dexTransactionStore: DexTransactionsStorage
    
    var tokensObserver: NotificationToken?
    
    private lazy var headerView: Dex4DAccountHeaderView = {
        let view = Dex4DAccountHeaderView()
        view.delegate = self
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(Dex4DAccountCell.self, forCellReuseIdentifier: NSStringFromClass(Dex4DAccountCell.self))
        return tableView
    }()
    
    init(
        keystore: Keystore,
        account: WalletInfo,
        viewModel: DexAccountViewModel,
        dexTransactionStore: DexTransactionsStorage
    ) {
        self.keystore = keystore
        self.account = account
        self.viewModel = viewModel
        self.dexTransactionStore = dexTransactionStore
        super.init(nibName: nil, bundle: nil)
        self.headerView.configHeaderView(with: viewModel)
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "D4D Account".localized
        
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(headerView.bounds.size.height)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NotificationNames.refreshDexAccountInfoNotify, object: nil)
        
        tokensObserver = dexTransactionStore.transactions.observe { [weak self] (changes: RealmCollectionChange) in
            guard let `self` = self else { return }
            switch changes {
            case .initial, .update:
                self.tableView.reloadData()
            case .error: break
            }
        }
    }
    
    @objc func refresh() {
        headerView.configHeaderView(with: viewModel)
        tableView.reloadData()
    }
    
    deinit {
        tokensObserver?.invalidate()
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension Dex4DAccountViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = viewModel.pools?.count {
            return count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(Dex4DAccountCell.self)) as! Dex4DAccountCell
        if let pools = viewModel.pools {
            let pool = pools[indexPath.row]
            let tokenObject = viewModel.tokenObjects.filter { $0.name == pool.tokenName }.first
            var transactions: [DexTransaction] = []
            dexTransactionStore.pendingObjects.forEach { transaction in
                guard transaction.type != "withdraw" else { return }
                if transaction.type == "swap" {
                    let coins = transaction.Tokens.components(separatedBy: "/")
                    if let symbol = coins.first, symbol == pool.tokenName {
                        transactions.append(transaction)
                    }
                } else {
                    let coins = transaction.Tokens.components(separatedBy: "/")
                    if let symbol = coins.last, symbol == pool.tokenName {
                        transactions.append(transaction)
                    }
                }
            }
            cell.configAccountCell(with: pool, token: tokenObject, transactions: transactions)
        }
        cell.delegate = self
        cell.viewDelegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let pools = viewModel.pools {
            let pool = pools[indexPath.row]
            return pool.games.count > 0 ? 220 : 165
        }
        return 165
    }
}

extension Dex4DAccountViewController: Dex4DAccountHeaderViewDelegate {
    func didSelectWithdrawButton() {
        delegate?.didPressedWithdraw(for: viewModel, viewController: self)
    }
    func didSelectTransactionsButton() {
        delegate?.checkoutTransaction(in: self)
    }
}

extension Dex4DAccountViewController: Dex4DAccountCellDelegate {
    func didPressedTradeButton(model: DexPool) {
        delegate?.didSelectedTradeOperation(for: model, viewModel: viewModel, viewController: self)
    }
}

extension Dex4DAccountViewController: Dex4DAccountCollectionViewDelegate {
    func didSelectItem(at index: Int) {
        print(index)
    }
}

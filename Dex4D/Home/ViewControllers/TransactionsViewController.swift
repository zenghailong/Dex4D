//
//  TransactionsViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import RealmSwift

class TransactionsViewController: BaseViewController {
    
    private lazy var headerView: TransactionsHeaderView = {
        let view = TransactionsHeaderView()
        view.delegate = self
        return view
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = .clear
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 10))
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.register(TransactionsTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TransactionsTableViewCell.self))
        return tableView
    }()
    
    let dexTransactionStore: DexTransactionsStorage
    
    var transactionsObserver: NotificationToken?
    
    var selectedType: Dex4DTransactionsType = .all
    var selectedStatus: DexTransactionsStatus = .all
    var filterTransactions: [DexTransaction] = []
    
    init(
        dexTransactionStore: DexTransactionsStorage,
        selectedType: Dex4DTransactionsType = .all,
        selectedStatus: DexTransactionsStatus = .all
    ) {
        self.dexTransactionStore = dexTransactionStore
        self.selectedType = selectedType
        self.selectedStatus = selectedStatus
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = "Transaction".localized
        
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
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
           self.automaticallyAdjustsScrollViewInsets = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.getFilterTransactions), name: NotificationNames.transactionsValueChanged, object: nil)
        transactionsObserver = dexTransactionStore.transactions.observe {[weak self] (changes: RealmCollectionChange) in
             guard let `self` = self else { return }
            switch changes {
            case .initial, .update:
                self.getFilterTransactions()
            case .error(let error):
                fatalError("\(error)")
            }
        }
        self.getFilterTransactions()
    }
    
    @objc func getFilterTransactions() {
        var transactions: [DexTransaction] = []
        switch selectedStatus {
        case .all:
            transactions = dexTransactionStore.allObjects
        case .success:
            transactions = dexTransactionStore.successObjects
        case .failed:
            transactions = dexTransactionStore.failedObjects
        case .pending:
            transactions = dexTransactionStore.pendingObjects
        }
        switch selectedType {
        case .all:
            filterTransactions = transactions
        default:
            filterTransactions = transactions.filter { $0.type.convertFirstLetterToUppercase() == selectedType.description}
        }
        tableView.reloadData()
    }
    
    deinit {
        transactionsObserver?.invalidate()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterTransactions.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(TransactionsTableViewCell.self)) as! TransactionsTableViewCell
        cell.configCell(wtih: filterTransactions[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let hash = filterTransactions[indexPath.row].id
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        if let main = appDelegate.coordinator.coordinators.first as? MainCoordinator {
            main.browserCoordinator.rootViewController.urlString = Dex4DUrls.hash + hash
            print(Dex4DUrls.hash + hash)
            main.browserCoordinator.rootViewController.urlString = Dex4DUrls.hash + hash

            main.tabBarController.selectedIndex = 2
            navigationController?.popToRootViewController(animated: false)
        }
    }
}

extension TransactionsViewController: TransactionsHeaderViewDelegate {
    func filterTransactions(with selectedType: Dex4DTransactionsType, selectedStatus: DexTransactionsStatus) {
        self.selectedType = selectedType
        self.selectedStatus = selectedStatus
        getFilterTransactions()
    }
}

extension TransactionsViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let off_y = scrollView.contentOffset.y
        if off_y < 0 {
            self.tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
}

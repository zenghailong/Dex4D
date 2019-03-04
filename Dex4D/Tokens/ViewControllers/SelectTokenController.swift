//
//  SelectTokenController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/17.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class SelectTokenController: BaseViewController {

    let titleText: String
    
    let store: TokensDataStore
    
    init(titleText: String, store: TokensDataStore) {
        self.titleText = titleText
        self.store = store
        super.init(nibName: nil, bundle: nil)
    }
    
    private let tableHeaderView: UIView = {
        let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: 20))
        tableHeaderView.backgroundColor = .clear
        return tableHeaderView
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.register(R.nib.assetViewCell(), forCellReuseIdentifier: R.nib.assetViewCell.name)
        tableView.tableHeaderView = tableHeaderView
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = titleText
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(navigationBar.snp.bottom)
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SelectTokenController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return store.tokens.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.assetViewCell.name) as! AssetViewCell
        cell.balanceLabel.isHidden = true
        cell.cover.isEnabled = true
        cell.configCell(hide: false, token: store.tokens[indexPath.row])
        cell.didSelectedToken = {[weak self] tokenObject in
            guard let strongSelf = self else { return }
            NotificationCenter.default.post(name: NotificationNames.selectedTokenNotify, object: tokenObject)
            strongSelf.navigationController?.popViewController(animated: true)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 59
    }
}

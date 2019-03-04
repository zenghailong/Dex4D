//
//  BaseTableViewController.swift
//  DAPPBrowser
//
//  Created by ColdChains on 2018/9/13.
//  Copyright © 2018 ColdChains. All rights reserved.
//

import UIKit

class BaseTableViewController: BaseViewController {
    
    var dataSource: [CellModel] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: CGRect(), style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView()
        tableView.tableFooterView = UIView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        tableView.register(CommonTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(CommonTableViewCell.self))
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    override func setCustomNavigationbar() {
        super.setCustomNavigationbar()
        setTableViewTopConstraint(top: Constants.NavigationBarHeight)
    }
    
    func setTableViewTopConstraint(top: CGFloat) {
        tableView.snp.updateConstraints { (make) in
            make.top.equalToSuperview().offset(top)
        }
    }
    
}

extension BaseTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 63
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CommonTableViewCell.self)) as! CommonTableViewCell
        cell.setupData(style: .common, model: dataSource[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        if let vc = swiftClassFromString(className: dataSource[indexPath.row].push) {
            navigationController?.pushViewController(vc, animated: true)
        }
        if let action = dataSource[indexPath.row].action {
            if self.responds(to: Selector(action)) {
                let control: UIControl = UIControl()
                control.sendAction(Selector(action), to: self, for: nil)
            }
        }
    }

}

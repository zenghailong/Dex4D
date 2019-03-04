//
//  ClearCacheViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/11/8.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class ClearCacheViewController: BaseTableViewController {
    
    let viewModel = ClearCacheViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.title
        dataSource = viewModel.dataSource
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CommonTableViewCell.self)) as! CommonTableViewCell
        cell.setupData(style: .language, model: viewModel.dataSource[indexPath.row])
        return cell
    }
    
    @objc private func clearCache() {
        ClearCacheManage.clearAllCache()
        showTipsMessage(message: "Clear success".localized)
    }
    
}

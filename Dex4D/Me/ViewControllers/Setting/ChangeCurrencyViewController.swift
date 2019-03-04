//
//  ChangeCurrencyViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class ChangeCurrencyViewController: BaseTableViewController {
    
    let viewModel = ChangeViewModel(type: .currency)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.title
        dataSource = viewModel.dataSource
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(CommonTableViewCell.self)) as! CommonTableViewCell
        cell.setupData(style: .currency, model: viewModel.dataSource[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let currency = viewModel.dataSource[indexPath.row].value as? Currency {
            LocalizationTool.shared.setCurrency(currency: currency)
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            delegate.coordinator.enterApp(inputPin: false)
//            NotificationCenter.default.post(name: Notifications.refreshCurrency, object: nil)
        }
    }
    
}

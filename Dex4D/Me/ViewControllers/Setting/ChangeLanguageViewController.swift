//
//  ChangeLanguageViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class ChangeLanguageViewController: BaseTableViewController {
    
    let viewModel = ChangeViewModel(type: .language)

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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let language = viewModel.dataSource[indexPath.row].value as? Language {
            LocalizationTool.shared.setLanguage(language: language)
            guard let delegate = UIApplication.shared.delegate as? AppDelegate else { return }
            delegate.coordinator.enterApp(inputPin: false)
//            for coordinator in delegate.coordinator.coordinators {
//                guard let main = coordinator as? MainCoordinator else { continue }
//                let coordinators = main.coordinators
//                for index in 0..<coordinators.count {
//                    guard let me = coordinators[index] as? MeCoordinator else { continue }
//                    main.tabBarController.selectedIndex = index
//                    me.pushToSetting()
//                }
//            }
            if let app = UIApplication.shared.delegate as? AppDelegate {
                app.createShortcutItems()
            }
        }
    }

}

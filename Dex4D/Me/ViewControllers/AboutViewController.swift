//
//  VersionViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/9/27.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class AboutViewController: BaseTableViewController {
    
    let viewModel = AboutViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = viewModel.title
        dataSource = viewModel.dataSource
    }
        
    @objc private func pushToHelp() {
        let vc = BaseWebViewController(urlString: Dex4DUrls.wiki)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func checkUpdate() {
        AppUpdateManager().check(showLast: true)
    }

}

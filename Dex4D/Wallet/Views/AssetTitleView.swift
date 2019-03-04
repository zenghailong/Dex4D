//
//  AssetTitleView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/16.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class AssetTitleView: UIView {

    @IBOutlet weak var assetLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        assetLabel.text = "Asset".localized
    }

}

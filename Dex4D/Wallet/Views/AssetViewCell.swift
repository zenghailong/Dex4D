//
//  AssetViewCell.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/16.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit
import BigInt

class AssetViewCell: UITableViewCell {

    var token: TokenObject?
    
    var didSelectedToken: ((TokenObject) -> Void)?
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var cover: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.layer.masksToBounds = true
    }
    
    func configCell(hide: Bool, token: TokenObject) {
        self.token = token
        iconView.image = UIImage(named: token.logo)
        symbolLabel.text = token.symbol
        if hide {
            balanceLabel.text = "******"
        } else {
            balanceLabel.text = token.value.doubleValue == 0 ? TokenObject.DEFAULT_VALUE : Double(token.value)?.stringFloor6Value()
        }
    }
    
    @IBAction func didSelectedTokenItem(_ sender: UIButton) {
        didSelectedToken?(token!)
    }
    
}

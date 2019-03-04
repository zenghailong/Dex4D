//
//  Dex4DAccountCollectionViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/15.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import Kingfisher

class Dex4DAccountCollectionViewCell: UICollectionViewCell {
    
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_eth()
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.addSubview(iconImageView)
        iconImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalTo(25)
            make.height.equalTo(25)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func set(game: Dex4DGame) {
        iconImageView.kf.setImage(
            with: URL(string: game.logo),
            placeholder: R.image.token_placeHolder(),
            options: nil, progressBlock: nil,
            completionHandler: nil
        )
    }
    
}

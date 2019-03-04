//
//  CommonTableViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

enum CommonTableViewCellStyle {
    case common
    case language
    case currency
}

class CommonTableViewCell: UITableViewCell {
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = Colors.cellBackground
        view.layer.cornerRadius = Constants.cornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var headImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_setting()
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Setting"
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var detailImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_right()
        return imageView
    }()
    
    private lazy var okImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = R.image.icon_select()
        imageView.isHidden = true
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        self.backgroundColor = .clear
        
        self.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(10)
        }
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(headImageView.snp.right).offset(10)
        }
        
        containerView.addSubview(detailImageView)
        detailImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-15)
        }
        
        containerView.addSubview(okImageView)
        okImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupData(style: CommonTableViewCellStyle, model: CellModel) {
        headImageView.image = model.image
        nameLabel.text = model.title
        if model.image == nil {
            headImageView.snp.updateConstraints { (make) in
                make.left.equalTo(0)
            }
        } else {
            headImageView.snp.updateConstraints { (make) in
                make.left.equalToSuperview().offset(10)
            }
        }
        if let text = model.detail {
            print(text)
            detailLabel.text = text
            detailImageView.isHidden = true
        } else {
            detailImageView.isHidden = false
        }
        okImageView.isHidden = true
        if style == .language {
            detailImageView.isHidden = true
            if model.value as? Language == LocalizationTool.shared.currentLanguage {
                selectCurrentCell = true
            }
        }
        if style == .currency {
            detailImageView.isHidden = true
            if model.value as? Currency == LocalizationTool.shared.currentCurrency {
                selectCurrentCell = true
            }
        }
    }
    
    var selectCurrentCell = false {
        didSet {
            okImageView.isHidden = !selectCurrentCell
        }
    }
    
}

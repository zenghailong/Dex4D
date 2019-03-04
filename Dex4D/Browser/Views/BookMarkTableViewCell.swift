//
//  BookMarkTableViewCell.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/22.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class BookMarkTableViewCell: UITableViewCell {
    
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
        label.text = "dapp name"
        label.textColor = .white
        label.font = UIFont.defaultFont(size: 14)
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.text = "desc"
        label.textColor = Colors.textAlpha
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "7D8091")
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.setImage(nil, for: .normal)
        button.setImage(R.image.icon_select_white(), for: .selected)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
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
            make.width.height.equalTo(40)
        }
        
        containerView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalTo(headImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-50)
        }
        
        containerView.addSubview(detailLabel)
        detailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.left.equalTo(headImageView.snp.right).offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        containerView.addSubview(selectButton)
        selectButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
            make.width.height.equalTo(20)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showSelectButton() {
        selectButton.isSelected = false
        selectButton.isHidden = false
        detailLabel.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(-50)
        }
    }
    
    func hideSelectButton() {
        selectButton.isHidden = true
        detailLabel.snp.updateConstraints { (make) in
            make.right.equalToSuperview().offset(-10)
        }
    }
    
    func setBookmark(model: Bookmark) {
        nameLabel.text = model.title
        detailLabel.text = model.url
        if model.icon == "" {
            headImageView.snp.updateConstraints { (make) in
                make.width.equalTo(0)
                make.left.equalTo(0)
            }
        } else {
            headImageView.snp.updateConstraints { (make) in
                make.width.equalTo(40)
                make.left.equalToSuperview().offset(10)
            }
        }
    }
    
}

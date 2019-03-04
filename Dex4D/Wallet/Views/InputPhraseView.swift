//
//  InputPhraseView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol InputPhraseViewDelegate: class {
    func didSelectItem(word: String)
}

final class InputPhraseView: UIView {
    
    weak var delegate: InputPhraseViewDelegate?
    
    //    lazy var layout: UICollectionViewLayout = {
    //        let layout = UICollectionViewFlowLayout()
    //        layout.minimumLineSpacing = 10
    //        layout.minimumInteritemSpacing = 8
    //        layout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
    //        layout.sectionInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    //        return layout
    //    }()
    
    lazy var collectionView: DynamicCollectionView = {
        let collectionView = DynamicCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    @objc dynamic var words: [String] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor(hex: "393948")
        self.layer.cornerRadius = 5.0
        
        addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "InputPhraseViewIndentifier")
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension InputPhraseView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "InputPhraseViewIndentifier", for: indexPath)
        
        if cell.subviews.count > 1 {
            let subview = cell.subviews.last
            subview?.removeFromSuperview()
        }
        let wordLabel = UILabel()
        wordLabel.font = UIFont.systemFont(ofSize: 16)
        wordLabel.textAlignment = .center
        wordLabel.textColor = .white
        cell.addSubview(wordLabel)
        wordLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        wordLabel.text = words[indexPath.item]
        
        cell.layer.cornerRadius = 12.5
        cell.layer.masksToBounds = true
        cell.layer.borderColor = Colors.globalColor.cgColor
        cell.layer.borderWidth = 1.0
        return cell
    }
}

extension InputPhraseView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let str = words[indexPath.item]
        let width = str.calcuateLabSizeWidth(font: UIFont.systemFont(ofSize: 16), maxHeight: collectionView.frame.size.width)
        return CGSize(width: width + 16, height: 24)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.didSelectItem(word: words[indexPath.item])
        words.remove(at: indexPath.row)
        collectionView.reloadData()
    }
    
}


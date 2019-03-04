//
//  EnterPhraseView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol EnterPhraseViewDelegate: class {
    func didSelectedItem(word: String, isDelete: Bool)
}

class EnterPhraseView: UIView {
    
    struct Metric {
        static let itemWidth: CGFloat = 90
        static let itemHeight: CGFloat = 30
        static let row: Int = 4
    }
    weak var delegate: EnterPhraseViewDelegate?
    
    var collectionView: UICollectionView?
    
    private var words: [String] = []
    
    private lazy var statusArray: [Bool] = {
        var statuses: [Bool] = []
        for _ in 0..<self.words.count {
            statuses.append(false)
        }
        return statuses
    }()
    
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        let column = self.words.count / Metric.row
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: Metric.itemWidth, height: Metric.itemHeight)
        layout.minimumLineSpacing = (self.frame.size.height - CGFloat(Metric.row) * Metric.itemHeight) / CGFloat(Metric.row - 1)
        layout.minimumInteritemSpacing = (self.frame.size.width - CGFloat(column) * Metric.itemWidth) / CGFloat(column)
        layout.sectionInset = UIEdgeInsets.zero
        return layout
    }()
    
    init(frame: CGRect, words: [String]) {
        super.init(frame: frame)
        self.words = words
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "EnterPhraseViewIndentifier")
        collectionView?.backgroundColor = .clear
        collectionView?.delegate = self
        collectionView?.dataSource = self
        addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func cancelItem(word: String) {
        let arr = NSArray(array: words)
        statusArray[arr.index(of: word)] = false
        collectionView?.reloadData()
    }
    
}

extension EnterPhraseView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "EnterPhraseViewIndentifier", for: indexPath)
        var wordLabel: UILabel? = nil
        if cell.subviews.count == 1 {
            wordLabel = UILabel()
            wordLabel!.font = UIFont.systemFont(ofSize: 16)
            wordLabel!.textAlignment = .center
            wordLabel!.text = words[indexPath.item]
            cell.addSubview(wordLabel!)
            wordLabel!.snp.makeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        } else {
            wordLabel = cell.subviews.last as? UILabel
            wordLabel?.text = words[indexPath.item]
        }
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        let status = statusArray[indexPath.item]
        if status {
            cell.backgroundColor = Colors.buttonInvalid
            wordLabel!.textColor = UIColor.hexColor(rgbValue: 0xFFFFFF, alpha: 0.3)
        } else {
            cell.backgroundColor = Colors.globalColor
            wordLabel!.textColor = .white
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        statusArray[indexPath.item] = true
        delegate?.didSelectedItem(word: words[indexPath.item], isDelete: false)
//        let status = statusArray[indexPath.item]
//        delegate?.didSelectedItem(word: words[indexPath.item], isDelete: status)
//        statusArray[indexPath.item] = !status
        collectionView.reloadData()
    }
}



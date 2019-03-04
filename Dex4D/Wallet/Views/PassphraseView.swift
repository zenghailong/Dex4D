//
//  PassphraseView.swift
//  Dex4D
//
//  Created by zeng hai long on 15/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class PassphraseView: UIView {
    
    struct Metric {
        static let lineSpacing: CGFloat = 1.0
        static let lineCount: Int = 3
    }
    
    var collectionView: UICollectionView?
    
    private var words: [String] = []
    
    fileprivate lazy var layout: UICollectionViewFlowLayout = {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = Metric.lineSpacing
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets.zero
        return layout
    }()
    
    init(frame: CGRect, words: [String]) {
        super.init(frame: frame)
        self.words = words
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
        collectionView?.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "PassphraseViewIndentifier")
        collectionView?.backgroundColor = .clear
        collectionView?.delegate = self
        collectionView?.dataSource = self
        addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.edges.equalToSuperview()
        })
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layout.itemSize = CGSize(width: self.frame.size.width / CGFloat(Metric.lineCount), height: (self.frame.size.height - CGFloat(self.words.count / Metric.lineCount) * Metric.lineSpacing) / CGFloat(self.words.count / Metric.lineCount))
        layout.invalidateLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PassphraseView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return words.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PassphraseViewIndentifier", for: indexPath)
        cell.backgroundColor = UIColor(hex: "393948")
        let wordLabel = UILabel()
        wordLabel.textColor = .white
        wordLabel.font = UIFont.systemFont(ofSize: 16)
        wordLabel.textAlignment = .center
        wordLabel.text = words[indexPath.item]
        cell.addSubview(wordLabel)
        wordLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        return cell
    }
    
}

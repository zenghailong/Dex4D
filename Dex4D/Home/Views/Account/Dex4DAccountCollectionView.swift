//
//  Dex4DAccountCollectionView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/15.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol Dex4DAccountCollectionViewDelegate: class {
    func didSelectItem(at index: Int)
}

class Dex4DAccountCollectionView: UICollectionView {
    
    weak var viewDelegate: Dex4DAccountCollectionViewDelegate?
    
    var dataArray: [Dex4DGame] = []

    init() {
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 49, height: 49)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        super.init(frame: CGRect(), collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.register(Dex4DAccountCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(Dex4DAccountCollectionViewCell.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension Dex4DAccountCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(Dex4DAccountCollectionViewCell.self), for: indexPath) as! Dex4DAccountCollectionViewCell
        cell.set(game: dataArray[indexPath.row])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
        viewDelegate?.didSelectItem(at: indexPath.row)
    }
}

//
//  TransactionsMenuView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

enum TransactionsMenu {
    case status
    case type
}
protocol TransactionsMenuViewDelegate: class {
    func didSelectedFilterButton()
}

class TransactionsMenuView: UICollectionView {
    
    weak var menuDelegate: TransactionsMenuViewDelegate?
    
    let typeArray: [Dex4DTransactionsType]
    let statusArray: [DexTransactionsStatus]
    let menuType: TransactionsMenu
    var selectedType: Dex4DTransactionsType = .all
    var selectedStatus: DexTransactionsStatus = .all

    init(
        typeArray: [Dex4DTransactionsType],
        statusArray: [DexTransactionsStatus],
        menuType: TransactionsMenu
    ) {
        self.typeArray = typeArray
        self.statusArray = statusArray
        self.menuType = menuType
        let layout = UICollectionViewFlowLayout.init()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = LocalizationTool.shared.currentLanguage == .english ? 0 : 5
        layout.scrollDirection = .horizontal
        
        super.init(frame: CGRect(), collectionViewLayout: layout)
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .clear
        self.showsHorizontalScrollIndicator = false
        self.register(TransactionsMenuViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(TransactionsMenuViewCell.self))
    }
    
    func setupCellStatus(count: Int, indexPath: IndexPath) {
        for i in 0..<count {
            if let cell = cellForItem(at: IndexPath(item: i, section: 0)) as? TransactionsMenuViewCell {
                if cell.isCurrent {
                    cell.setStatusNormal()
                }
            }
        }
        if let cell = cellForItem(at: indexPath) as? TransactionsMenuViewCell {
            cell.setStatusSeleted()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionsMenuView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch menuType {
        case .status: return statusArray.count
        case .type: return typeArray.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let titleText: String
        switch menuType {
        case .status:
            let item = statusArray[indexPath.item]
            titleText = item.description.localized
        case .type:
            let item = typeArray[indexPath.item]
            titleText = item.description.localized
        }
        let width = titleText.calcuateLabSizeWidth(font: UIFont.systemFont(ofSize: 14), maxHeight: collectionView.frame.size.width)
        let sideWidth: CGFloat = Constants.ScreenWidth > 375 ? 15 : 10
        return CGSize(width: width + 2 * sideWidth, height: 25)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TransactionsMenuViewCell.self), for: indexPath) as! TransactionsMenuViewCell
        let titleText: String
        switch menuType {
        case .status:
            let item = statusArray[indexPath.item]
            titleText = item.description.localized
        case .type:
            let item = typeArray[indexPath.item]
            titleText = item.description.localized
        }
        cell.setText(text: titleText)
        if indexPath.item == 0 {
            cell.setStatusSeleted()
        } else {
            cell.setStatusNormal()
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch menuType {
        case .status:
            selectedStatus = statusArray[indexPath.item]
            setupCellStatus(count: statusArray.count, indexPath: indexPath)
        case .type:
            selectedType = typeArray[indexPath.item]
            setupCellStatus(count: typeArray.count, indexPath: indexPath)
        }
        menuDelegate?.didSelectedFilterButton()
    }
}

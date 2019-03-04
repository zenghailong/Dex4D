//
//  DynamicCollectionView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

final class DynamicCollectionView: UICollectionView {

    override func layoutSubviews() {
        super.layoutSubviews()
        if !__CGSizeEqualToSize(bounds.size, self.intrinsicContentSize) {
            self.invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return collectionViewLayout.collectionViewContentSize
    }

}

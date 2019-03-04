//
//  SelectImportView.swift
//  Dex4D
//
//  Created by zeng hai long on 21/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

enum ImportSelectionType {
    case keystore
    case mnemonic
}

class SelectImportView: UIView {
    
    var importSelectType: ImportSelectionType?
    
    var selectImportStyleBlock: ((ImportSelectionType) -> Void)?
    
    var titleText: String? {
        didSet {
            importWayLabel.text = titleText
        }
    }

    @IBOutlet weak var importWayLabel: UILabel!
    
    @IBOutlet weak var importButton: UIButton!
    
    @IBAction func `import`(_ sender: Any) {
        if let importSelectType = importSelectType {
           selectImportStyleBlock?(importSelectType)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = Constants.cornerRadius
        layer.masksToBounds = true
        backgroundColor = Colors.cellBackground
    }
    
}

//
//  TradeSectionHeaderView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

protocol TradeSectionHeaderViewDelegate: class {
    func didSelectItem(type: Dex4DTradeType)
}

class TradeSectionHeaderView: UIView {
    
    weak var delegate: TradeSectionHeaderViewDelegate?
    
    let actionTypes: [Dex4DTradeType]
    var previousSelectedBtn: UIButton? = .none
    var selectedType: Dex4DTradeType? = .none
    
    init(actionTypes: Array<Dex4DTradeType>) {
        self.actionTypes = actionTypes
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 30))
        self.backgroundColor = Colors.cellBackground
        
        for (index, type) in actionTypes.enumerated() {
            let button = UIButton(type: .custom)
            button.setTitle(type.description, for: .normal)
            button.setTitleColor(Colors.textTips, for: .normal)
            button.titleLabel?.font = UIFont.defaultFont(size: 16)
            button.addTarget(self, action: #selector(self.buttonAction(sender:)), for: .touchUpInside)
            let w = (Constants.ScreenWidth - 30) / 4
            button.frame = CGRect(x: w * CGFloat(index), y: 0, width: w, height: 30)
            self.addSubview(button)
            if index == 0 {
                buttonAction(sender: button)
            }
        }
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction(sender: UIButton) {
        
        var tradeType: Dex4DTradeType? = .none
        
        if let title = sender.currentTitle {
            switch title {
            case Dex4DTradeType.buy.description:
                tradeType = .buy
            case Dex4DTradeType.reinvest.description:
                tradeType = .reinvest
            case Dex4DTradeType.sell.description:
                tradeType = .sell
            case Dex4DTradeType.swap.description:
                tradeType = .swap
            default:
                break
            }
        }
        if sender == previousSelectedBtn { return }
        if let tradeType = tradeType {
            delegate?.didSelectItem(type: tradeType)
            sender.setTitleColor(.white, for: .normal)
            sender.titleLabel?.font = UIFont.defaultFont(size: 18)
            previousSelectedBtn?.setTitleColor(Colors.textTips, for: .normal)
            previousSelectedBtn?.titleLabel?.font = UIFont.defaultFont(size: 16)
            previousSelectedBtn = sender
        }
    }
}

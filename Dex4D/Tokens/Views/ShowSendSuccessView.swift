//
//  ShowSendSuccessView.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/22.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol ShowSendSuccessViewDelegate: class {
    func didSelectTxHashButton()
}

class ShowSendSuccessView: UIView {
    
    weak var delegate: ShowSendSuccessViewDelegate?
    
    @IBOutlet weak var sendAmountTitleLabel: UILabel!
    @IBOutlet weak var sendAmountLabel: UILabel!
    @IBOutlet weak var pendingLabel: UILabel!
    
    @IBOutlet weak var fromTitleLabel: UILabel!
    @IBOutlet weak var toTitleLabel: UILabel!
    @IBOutlet weak var gasTitleLabel: UILabel!
    @IBOutlet weak var txsHashTitleLabel: UILabel!
    
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var gasLabel: UILabel!
    @IBOutlet weak var txHashLabel: UILabel!
    @IBOutlet weak var txHashButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        pendingLabel.text = "Pending".localized
        fromTitleLabel.text = "From".localized
        toTitleLabel.text = "To".localized
        gasTitleLabel.text = "Actual Tx Cost/Fee".localized
        txsHashTitleLabel.text = "TxsHash".localized
        
        txHashButton.setTitleColor(Colors.globalColor, for: .normal)
        txHashButton.titleLabel?.font = UIFont.defaultFont(size: 14)
    }
    
    func configure(with viewModel: ShowSendSuccessViewModel) {
        switch viewModel.transfer.type {
        case .ether, .token:
            sendAmountTitleLabel.text = "Send amount".localized
            sendAmountLabel.text = viewModel.amount
        case .dapp: break
        }
        fromLabel.text = viewModel.from
        toLabel.text = viewModel.to
        gasLabel.text = viewModel.gas + " ETH"
        txHashButton.setTitle(viewModel.txHashValue, for: .normal)
    }
    
    @IBAction func txHashButtonAction(_ sender: UIButton) {
        delegate?.didSelectTxHashButton()
    }
}

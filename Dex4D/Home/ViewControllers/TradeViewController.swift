//
//  TradeViewController.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit
import BigInt
import RealmSwift

protocol TradeViewControllerDelegate: class {
    func didCancelTradeAction(in viewController: UIViewController)
    func didPressConfirm(
        transaction: DexUnconfirmedTransaction,
        transfer: Dex4DTransfer,
        token: DexTokenObject,
        type: D4DTransferActionType,
        amount: String,
        in viewController: UIViewController
    )
}

class TradeViewController: BaseViewController {
    
    weak var delegate: TradeViewControllerDelegate?
    
    private lazy var headerView: TradeHeaderView = {
        let view = TradeHeaderView(
            pool: pool,
            dexTokenStorage: dexTokenStorage,
            accountViewModel: viewModel
        )
        return view
    }()
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = Colors.cellBackground
        return view
    }()
    
    private lazy var sectionView: TradeSectionHeaderView = {
        let view = TradeSectionHeaderView(actionTypes: [.buy, .reinvest, .sell, .swap])
        view.delegate = self
        return view
    }()
    
    private lazy var buyView: Dex4DTradeView = {
        let view = Dex4DTradeView(
            style: .buy(token: pool.tokenName, walletBalance: tokenObject.value.doubleValue),
            coin: pool.tokenName,
            chainState: chainState,
            store: dexTokenStorage,
            navigationController: self.navigationController!
        )
        view.delegate = self
        return view
    }()
    
    private lazy var reinvestView: Dex4DTradeView = {
        let view = Dex4DTradeView(
            style: .reinvest(token: pool.tokenName, reinvestBalance: pool.revenue ?? 0),
            coin: pool.tokenName,
            chainState: chainState,
            store: dexTokenStorage,
            navigationController: self.navigationController!
        )
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private lazy var sellView: Dex4DTradeView = {
        let view = Dex4DTradeView(
            style: .sell(token: pool.tokenName, DexBalance: pool.d4dCount ?? 0),
            coin: pool.tokenName,
            chainState: chainState,
            store: dexTokenStorage,
            navigationController: self.navigationController!
        )
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private lazy var swapView: Dex4DTradeView = {
        let view = Dex4DTradeView(
            style: .swap(token: pool.tokenName, DexBalance: pool.d4dCount ?? 0),
            coin: pool.tokenName,
            chainState: chainState,
            store: dexTokenStorage,
            navigationController: self.navigationController!
        )
        view.delegate = self
        view.isHidden = true
        return view
    }()
    
    private var hasDex4DSwapAuthority = false
    
    private lazy var swapLockView: SwapLockView = {
        let view = SwapLockView(dexToken: dexToken)
        view.isHidden = true
        return view
    }()
    
    private lazy var actionInvalidView: SwapLockView = {
        let view = SwapLockView(dexToken: dexToken)
        view.backgroundColor = Colors.cellBackground
        return view
    }()
    
    private var data = Data()
    
    let account: WalletInfo
    let pool: DexPool
    let viewModel: DexAccountViewModel
    let dexTokenStorage: DexTokenStorage
    let tokensStorage: TokensDataStore
    let tokenObject: TokenObject
    let chainState: ChainState
    let controllerViewModel: TradeControllerViewModel
    var dexToken: DexTokenObject = DexTokenObject()
    var transfer: Dex4DTransfer?
    var currentTradeView: Dex4DTradeView?
    
    init(
        account: WalletInfo,
        pool: DexPool,
        viewModel: DexAccountViewModel,
        dexTokenStorage: DexTokenStorage,
        tokensStorage: TokensDataStore,
        chainState: ChainState
    ) {
        self.account = account
        self.pool = pool
        self.viewModel = viewModel
        self.dexTokenStorage = dexTokenStorage
        self.tokensStorage = tokensStorage
        self.tokenObject = tokensStorage.tokens.filter { $0.symbol == pool.tokenName.uppercased() }.first ?? TokenObject()
        self.chainState = chainState
        self.controllerViewModel = TradeControllerViewModel(account: account)
        
        super.init(nibName: nil, bundle: nil)
        self.judgeSwapAuthority()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let tokensArr = dexTokenStorage.tokens as? Array<[String: Any]> {
            self.dexToken = tokensArr.compactMap {
                    return DexTokenObject.deserialize(from: $0)
                }.filter {
                    $0.name == pool.tokenName
                }.first ?? DexTokenObject()
        }
        
        setCustomNavigationbar()
        setBackButton()
        navigationBar.titleText = controllerViewModel.titleText
        initUI()
        reloadWalletBalance()
        NotificationCenter.default.addObserver(self, selector: #selector(self.refresh), name: NotificationNames.refreshDexAccountInfoNotify, object: nil)
    }
    
    @objc func refresh() {
        headerView.newTokenPool = viewModel.pools?.filter {[unowned self] in $0.tokenName == self.pool.tokenName}.first
    }
    
    private static func transferType(token: TokenObject, pool: DexPool, style: Dex4DTradeViewStyle) -> Dex4DTransfer {
        switch  style {
        case .buy:
            if pool.tokenName == "eth" {
                return Dex4DTransfer(server: RPCServer(), type: .ether)
            }
            return Dex4DTransfer(server: RPCServer(), type: .token)
        default:
            return Dex4DTransfer(server: RPCServer(), type: .token)
        }
        
    }
    
    func judgeSwapAuthority() {
        controllerViewModel.isHaveSwapAuthority {[weak self] isHasAuthority in
            self?.hasDex4DSwapAuthority = isHasAuthority
        }
    }
    
    deinit {
        delegate?.didCancelTradeAction(in: self)
        NotificationCenter.default.removeObserver(self)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        view.endEditing(true)
    }
    
    private func reloadWalletBalance() {
        if pool.tokenName == "eth" {
            buyView.viewModel.ethBalance(address: account.address.description) {[weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    let balanceStr = EtherNumberFormatter.short.string(from: balance.value, units: .ether)
                    let balanceValue = balanceStr.replacingOccurrences(of: ",", with: "").doubleValue
                    self.buyView.balanceLabel.text = "Wallet balance".localized + ": " + (balanceValue == 0 ? "0" : balanceValue.stringFloor6Value()) + " " + self.buyView.coin.uppercased()
                case .failure(_): break
                }
            }
        } else {
            buyView.viewModel.tokenBalance(address: account.address.description, contract: tokenObject.contractAddress.description) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success(let balance):
                    let balanceStr = EtherNumberFormatter.short.string(from: balance.value, units: .ether)
                    let balanceValue = balanceStr.replacingOccurrences(of: ",", with: "").doubleValue
                    self.buyView.balanceLabel.text = "Wallet balance".localized + ": " + (balanceValue == 0 ? "0" : balanceValue.stringFloor6Value()) + " " + self.buyView.coin.uppercased()
                case .failure(_): break
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TradeViewController: Dex4DTradeViewDelegate {
    
    func didPressedSubmitButton(in tradeView: Dex4DTradeView) {
        guard tradeView.isInputValid == true else {
            showTipsMessage(message: Errors.wrongInput.errorDescription)
            return
        }
        
        transfer = TradeViewController.transferType(token: TokenObject(), pool: pool, style: tradeView.style)
        
        guard let transferObject = transfer else { return }
        let parsedValue: BigInt? = {
            switch transferObject.type {
            case .ether:
                return EtherNumberFormatter.full.number(from: tradeView.transferAmount, units: .ether)
            case .token:
                return EtherNumberFormatter.full.number(from: tradeView.transferAmount, decimals: DexConfig.decimals)
            }
        }()
        
        guard let value = parsedValue else {
            showTipsMessage(message: Errors.invalidAmount.errorDescription)
            return 
        }
        
        let tokens = viewModel.tokenObjects
        let token = tokens.filter { $0.name == pool.tokenName }.first
        
        var toAddress: String?
        var transferActionType: D4DTransferActionType?
        
        switch tradeView.style {
        case .buy(let tokenName, _):
            toAddress = tokenName == "eth" ? DexConfig.dex_protocol : token?.token_addr
            transferActionType = D4DTransferActionType.buy(token: tokenName)
        case .reinvest(let tokenName, _):
            toAddress = DexConfig.dex_protocol
            transferActionType = D4DTransferActionType.reinvest(token: tokenName)
        case .sell(let tokenName, _):
            toAddress = DexConfig.dex_protocol
            transferActionType = D4DTransferActionType.sell(token: tokenName)
        case .swap(let tokenName, _):
            toAddress = DexConfig.dex_protocol
            transferActionType = D4DTransferActionType.swap(token: tokenName, toSymbol: swapView.selectedToken?.name ?? "eth")
        case .withdraw: break
        }
        
        guard let to = toAddress else {
            return
        }
        let transaction = DexUnconfirmedTransaction(
            transfer: transferObject,
            value: value,
            to: EthereumAddress(string: to),
            data: data,
            gasLimit: .none,
            gasPrice: chainState.gasPrice,
            nonce: .none
        )
        
        let amount: String? = {
            switch tradeView.style {
            case .buy, .reinvest: return tradeView.tradeTextField.text
            case .sell, .swap: return tradeView.recievedCount
            default: return nil
            }
        }()
        
        if let token = token, let transferActionType = transferActionType, let amount = amount {
            delegate?.didPressConfirm(
                transaction: transaction,
                transfer: transferObject,
                token: token,
                type: transferActionType,
                amount: amount,
                in: self
            )
        }
    }
}

extension TradeViewController: TradeSectionHeaderViewDelegate {
    func didSelectItem(type: Dex4DTradeType) {
        if let currentTradeView = currentTradeView {
            currentTradeView.reset()
        }
        
        let arr = [buyView, reinvestView, sellView, (hasDex4DSwapAuthority && dexToken.tokenState == .regular) ? swapView : swapLockView]
        for i in 0..<arr.count {
            arr[i].isHidden = type.tradeTypeId == i + TRADE_TAG_BEGIN ? false : true
        }
        switch type {
        case .buy:
            currentTradeView = buyView
        case .reinvest:
            currentTradeView = reinvestView
        case .sell:
            currentTradeView = sellView
        case .swap:
            currentTradeView = hasDex4DSwapAuthority ? swapView : nil
        default: break
        }
        view.endEditing(true)
    }
}

extension TradeViewController {
    fileprivate func initUI() {
        view.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(headerView.bounds.size.height)
        }
        
        view.addSubview(containerView)
        containerView.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(15)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-(Constants.BottomBarHeight + 8))

        }
        
        containerView.addSubview(sectionView)
        sectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.right.equalToSuperview()
            make.height.equalTo(sectionView.bounds.size.height)
        }
        for view in [buyView, reinvestView, sellView, swapView, swapLockView] {
            containerView.addSubview(view)
            view.snp.makeConstraints { (make) in
                make.top.equalTo(sectionView.snp.bottom).offset(20)
                make.left.right.bottom.equalToSuperview()
            }
        }
        
        switch dexToken.tokenState {
        case .advisor, .delist:
           containerView.addSubview(actionInvalidView)
           actionInvalidView.snp.makeConstraints { (make) in
               make.top.equalTo(sectionView.snp.bottom).offset(20)
               make.left.right.bottom.equalToSuperview()
           }
        default: break
        }
    }
}

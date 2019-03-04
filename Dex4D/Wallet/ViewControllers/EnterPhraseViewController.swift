//
//  EnterPhraseViewController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/15.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

protocol EnterPhraseViewControllerDelegate: class {
    func didFinishedBackupPhrase(account: Wallet, in viewController: EnterPhraseViewController)
}

class EnterPhraseViewController: BaseViewController {
    
    weak var delegate: EnterPhraseViewControllerDelegate?
    
    let viewModel = EnterPhraseViewModel()
    let account: Wallet
    let words: [String]
    var randomWords: Array<String> = []
    
    private lazy var titleTextLabel: UILabel = {
        let textLabel = UILabel()
        textLabel.textAlignment = .center
        textLabel.textColor = UIColor.white
        textLabel.font = viewModel.titleFont
        textLabel.text = viewModel.titleText
        return textLabel
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let descLabel = UILabel()
        descLabel.textAlignment = .left
        descLabel.textColor = viewModel.descriptionTextColor
        descLabel.font = viewModel.descriptionFont
        descLabel.text = viewModel.description
        descLabel.numberOfLines = 0
        return descLabel
    }()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle(viewModel.inValidFinishedBtnText, for: .normal)
        button.setTitleColor(viewModel.inValidFinishedTextColor, for: .normal)
        button.backgroundColor = viewModel.inValidFinishedBtnColor
        button.titleLabel?.font = viewModel.finishedBtnTextFont
        button.layer.cornerRadius = Constants.BaseButtonHeight / 2
        button.isEnabled = false
        return button
    }()
    
    private lazy var enterPhraseView: EnterPhraseView = {
        let enterPhraseView = EnterPhraseView(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth - 2 * Constants.leftPadding, height: 162), words: randomWords)
        enterPhraseView.delegate = self
        return enterPhraseView
    }()
    
    private lazy var inputPhraseView: InputPhraseView = {
        let inputPhraseView = InputPhraseView()
        inputPhraseView.delegate = self
        return inputPhraseView
    }()
    
    var myContext = NSObject()
    
    init(
        account: Wallet,
        words: [String]
    ) {
        self.account = account
        self.words = words
        super.init(nibName: nil, bundle: nil)
        self.randomWords = words.shuffle()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubviews()
        inputPhraseView.addObserver(self, forKeyPath: "words", options: .new, context: &myContext)
        finishButton.addTarget(self, action: #selector(self.finish), for: .touchUpInside)
    }
    
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if let newValue = change?[NSKeyValueChangeKey.newKey] {
                let newWords = newValue as! [String]
                if newWords.count == words.count {
                    finishButton.isEnabled = true
                    finishButton.backgroundColor = Colors.globalColor
                    finishButton.setTitleColor(.white, for: .normal)
                } else {
                    finishButton.isEnabled = false
                    finishButton.backgroundColor = viewModel.inValidFinishedBtnColor
                    finishButton.setTitleColor(viewModel.inValidFinishedTextColor, for: .normal)
                }
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    @objc func finish() {
        let originWords = words.joined(separator: " ")
        let inputWords = inputPhraseView.words.joined(separator: " ")
        guard originWords == inputWords else {
            self.showTipsMessage(message: "Phrase is wrong".localized)
            return
        }
        delegate?.didFinishedBackupPhrase(account: account, in: self)
    }
    
    deinit {
        inputPhraseView.removeObserver(self, forKeyPath: "words", context: &myContext)
    }
    
    private func addSubviews() {
        setCustomNavigationbar()
        setBackButton()
        
        view.addSubview(titleTextLabel)
        titleTextLabel.snp.makeConstraints { (make) in
            make.top.equalTo(navigationBar.snp.bottom)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(descriptionLabel)
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleTextLabel.snp.bottom).offset(40 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(48)
            make.centerX.equalToSuperview()
        }
        
        view.addSubview(inputPhraseView)
        inputPhraseView.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(40 * Constants.ScaleHeight)
            make.left.equalToSuperview().offset(Constants.leftPadding)
            make.centerX.equalToSuperview()
            make.height.equalTo(120)
        }
        
        view.addSubview(enterPhraseView)
        enterPhraseView.snp.makeConstraints { (make) in
            make.top.equalTo(inputPhraseView.snp.bottom).offset(30 * Constants.ScaleHeight)
            make.left.equalTo(inputPhraseView.snp.left)
            make.centerX.equalToSuperview()
            make.height.equalTo(162)
        }
        
        view.addSubview(finishButton)
        finishButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(40 + Constants.BottomBarHeight))
            make.height.equalTo(Constants.BaseButtonHeight)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EnterPhraseViewController: EnterPhraseViewDelegate {
    func didSelectedItem(word: String, isDelete: Bool) {
        if isDelete {
            inputPhraseView.words = inputPhraseView.words.filter { $0 != word }
        } else {
            if !inputPhraseView.words.contains(word) {            
                inputPhraseView.words.append(word)
            }
        }
    }
}

extension EnterPhraseViewController: InputPhraseViewDelegate {
    func didSelectItem(word: String) {
        enterPhraseView.cancelItem(word: word)
    }
}

extension Array {
    public func shuffle() -> Array {
        var list = self
        for index in 0..<list.count {
            let newIndex = Int(arc4random_uniform(UInt32(list.count-index))) + index
            if index != newIndex {
                list.swapAt(index, newIndex)
            }
        }
        return list
    }
}

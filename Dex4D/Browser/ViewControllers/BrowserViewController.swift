//
//  BaseWebViewController.swift
//  DAPPBrowser
//
//  Created by ColdChains on 2018/9/13.
//  Copyright © 2018 ColdChains. All rights reserved.
//

import UIKit
import WebKit
import JavaScriptCore
import SnapKit
import CryptoSwift
import Result

enum DAppError: Error {
    case cancelled
}

protocol BrowserViewControllerDelegate: class {
    func didReceiveMessage(message: WKScriptMessage)
    func didSelectMenuItem()
    func didSelectCollectItem(sender: UIButton)
    func didVisitUrl(url: String, title: String?)
}

class BrowserViewController: UIViewController {
    
    weak var delegate: BrowserViewControllerDelegate?
    
    private struct Keys {
        static let developerExtrasEnabled = "developerExtrasEnabled"
        static let URL = "URL"
        static let title = "title"
        static let canGoBack = "canGoBack"
        static let estimatedProgress = "estimatedProgress"
    }
    
    var urlString: String = "" {
        didSet {
            startRequest(string: urlString)
        }
    }
    
    private lazy var userClient: String = {
        return Bundle.main.appDisplayName + "/" + Bundle.main.appVersion
    }()
    
    private lazy var navigationBar: WebViewNavigationBar = {
        let bar = WebViewNavigationBar()
        bar.delegate = self
        bar.urlTextField.delegate = self
        return bar
    }()
    
    private lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = Colors.globalColor
        progressView.trackTintColor = .clear
        return progressView
    }()
    
    private lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration.make(messageHandler: ScriptMessageProxy(delegate: self), address: account.currentAccount.address.description)
        config.websiteDataStore = WKWebsiteDataStore.default()
        return config
    }()
    
    lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: self.config
        )
        webView.isOpaque = false
        webView.backgroundColor = Colors.background
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        if isDebug {
            webView.configuration.preferences.setValue(true, forKey: Keys.developerExtrasEnabled)
        }
        return webView
    }()
    
    let account: WalletInfo
    
    init(account: WalletInfo) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
    }
    
    init(account: WalletInfo, urlString: String) {
        self.account = account
        super.init(nibName: nil, bundle: nil)
        self.urlString = urlString
    }
    
    private func injectUserAgent() {
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            guard let `self` = self, let currentUserAgent = result as? String else { return }
            self.webView.customUserAgent = currentUserAgent + " " + self.userClient
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(Constants.NavigationBarHeight)
        }
        
        view.addSubview(webView)
        webView.snp.makeConstraints({ (make) in
            make.top.equalToSuperview().offset(Constants.NavigationBarHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview()
        })
        
        view.addSubview(progressView)
        progressView.snp.makeConstraints({ (make) in
            make.top.equalTo(webView)
            make.left.equalTo(webView)
            make.right.equalTo(webView)
            make.height.equalTo(2)
        })
        
        webView.addObserver(self, forKeyPath: Keys.URL, options: [.new, .initial], context: nil)
        webView.addObserver(self, forKeyPath: Keys.title, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: Keys.canGoBack, options: .new, context: nil)
        webView.addObserver(self, forKeyPath: Keys.estimatedProgress, options: .new, context: nil)
        
        injectUserAgent()
        if urlString == "" {
            startRequest(string: Dex4DUrls.bowserHome)
        }
    }
    
//    deinit {
//        webView.removeObserver(self, forKeyPath: Keys.URL)
//        webView.removeObserver(self, forKeyPath: Keys.title)
//        webView.removeObserver(self, forKeyPath: Keys.canGoBack)
//        webView.removeObserver(self, forKeyPath: Keys.estimatedProgress)
//    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if keyPath == Keys.estimatedProgress {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.isHidden = progress == 1
                progressView.progress = progress
                //print(progress)
            }
        } else if keyPath == Keys.URL {
            navigationBar.urlTextField.text = webView.url?.absoluteString
            guard let url = webView.url?.absoluteString else { return }
            let selected = BookmarkStorage.shared.hasBookmark(url: url)
            setCollect(selected: selected)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        navigationBar.urlTextField.resignFirstResponder()
    }
    
    func startRequest() {
        guard let str = navigationBar.urlTextField.text == "" ? webView.url?.absoluteString : navigationBar.urlTextField.text else { return }
        guard let url = URL(string: str) else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        webView.load(request)
        tapAction()
    }
    
    func startRequest(string: String) {
        var str = string
        if str.hasPrefix(Dex4DUrls.base), str.components(separatedBy: "?").count == 1 {
            str += "?lang="
            str += LocalizationTool.shared.currentLanguage == .english ? "en" : "zh"
        }
        guard let url = URL(string: str) else { return }
        var request = URLRequest(url: url)
        request.cachePolicy = .returnCacheDataElseLoad
        webView.load(request)
        tapAction()
    }
    
    func notifyFinish(callbackID: Int, value: Result<DappCallback, DAppError>) {
        let script: String = {
            switch value {
            case .success(let result):
                return "executeCallback(\(callbackID), null, \"\(result.value.object)\")"
            case .failure(let error):
                return "executeCallback(\(callbackID), \"\(error)\", null)"
            }
        }()
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    @objc private func tapAction() {
        navigationBar.urlTextField.resignFirstResponder()
        navigationBar.urlTextField.text = webView.url?.absoluteString
        self.view.viewWithTag(10)?.removeFromSuperview()
    }
    
    func setCollect(selected: Bool) {
        navigationBar.setCollect(selected: selected)
    }
    
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish")
        guard let str = webView.url?.absoluteString else { return }
        delegate?.didVisitUrl(url: str, title: webView.title)
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("didCommit")
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail")
    }    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation")
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        navigationBar.urlTextField.text = webView.url?.absoluteString
        navigationBar.urlTextField.resignFirstResponder()
        decisionHandler(.allow)
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        return webView
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: .none, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            completionHandler()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: .none, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { _ in
            completionHandler(false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: .none, message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel".localized, style: .default, handler: { _ in
            completionHandler(nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        delegate?.didReceiveMessage(message: message)
    }
}

extension BrowserViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.selectedTextRange = textField.textRange(from: textField.beginningOfDocument, to: textField.endOfDocument)
        let view = UIView(frame: webView.frame)
        view.tag = 10
        view.backgroundColor = UIColor(displayP3Red: 0, green: 0, blue: 0, alpha: 0.1)
        self.view.addSubview(view)
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        view.addGestureRecognizer(tap)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        startRequest()
        tapAction()
        return true
    }
}

extension BrowserViewController: WebViewNavigationBarDelegate {
    func didSelectHomeButton() {
        startRequest(string: Dex4DUrls.bowserHome)
    }
    func didSelectCollectButton(sender: UIButton) {
        delegate?.didSelectCollectItem(sender: sender)
    }
    func didSelectMenuButton() {
        delegate?.didSelectMenuItem()
    }
}

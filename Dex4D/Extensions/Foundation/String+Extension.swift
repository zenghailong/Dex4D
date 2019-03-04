//
//  String+Extension.swift
//  Dex4D
//
//  Created by zeng hai long on 16/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

extension String {
    
    public func calcuateLabSizeWidth(font: UIFont, maxHeight: CGFloat) -> CGFloat {
        let attributes = [kCTFontAttributeName: font]
        let norStr = NSString(string: self)
        let size = norStr.boundingRect(with: CGSize(width: CGFloat(MAXFLOAT), height: maxHeight), options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context: nil)
        return size.width
    }
    
    public func calcuateLabSizeHeight(font: UIFont, maxWidth: CGFloat) -> CGFloat {
        let attributes = [kCTFontAttributeName: font]
        let norStr = NSString(string: self)
        let size = norStr.boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: attributes as [NSAttributedStringKey : Any], context: nil)
        return size.height
    }
    
    // 16 -> 10
    public func hexStringToInt() -> Int {
        var num = self
        if num.hasPrefix("0x") || num.hasPrefix("0X") {
            num.remove(at: num.index(from: 1))
        }
        let str = num.uppercased()
        var sum = 0
        for i in str.utf8 {
            sum = sum * 16 + Int(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    public func toAttributedString(color: UIColor = .white) -> NSMutableAttributedString {
        let str = NSMutableAttributedString(string: self)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        let dic: Dictionary<NSAttributedStringKey, Any> = [NSAttributedStringKey.foregroundColor: color,
//                                 NSAttributedStringKey.font: UIFont.defaultFont(size: 14),
                                 NSAttributedStringKey.paragraphStyle: paragraphStyle];
        str.setAttributes(dic, range: NSMakeRange(0, self.count))
        return str
    }
    
    func replaceBy(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)
    }
    
    public func isThan6DecimalPoints() -> Bool {
        if self.contains(".") {
            let parts = self.components(separatedBy: ".")
            if let lastPart = parts.last {
                if lastPart.count > 6 {
                    return true
                }
            }
        }
        return false
    }
}


extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return String(self[fromIndex...])
    }
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return String(self[..<toIndex])
    }
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return String(self[startIndex..<endIndex])
    }
    func floor6Value() -> String {
        let arr = self.components(separatedBy: CharacterSet(charactersIn: "."))
        if arr.count == 2 && arr[1].count > 6 {
            let first = arr.first!
            var last = arr.last!
            last = last.substring(to: 6)
            return first + "." + last
        }
        return self
    }
}


extension String {
    func isLegalNickName() -> Bool {
        let pattern = "^[A-Za-z][A-Za-z0-9]*$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
    func isPasswordString() -> Bool {
        let pattern = "^[0-9]*$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
    private func isNumberString() -> Bool {
        let pattern = "^[0-9.]*$"
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: self)
    }
    func isAmountString() -> Bool {
        if self.isNumberString() {
            return true
        }
        return false
    }
    func isEthereumAddress() -> Bool {
        if let _ = EthereumAddress(string: self) {
            return true
        }
        return false
    }
    func addressShortString() -> String {
        if self.isEthereumAddress() {
            return self.substring(to: 12) + "..." + self.substring(from: self.count - 10)
        }
        return self
    }
    func addressTitleString() -> String {
        return "Address".localized + ": " + self.addressShortString()
    }
}

extension String {
    private func qrStringParam(paramKey: String) -> String {
        guard let params = self.components(separatedBy: "?").last else {
            return ""
        }
        var appname = ""
        params.components(separatedBy: "&").forEach { (para) in
            if let key = para.components(separatedBy: "=").first,
                let value = para.components(separatedBy: "=").last,
                key == paramKey {
                appname = value
            }
        }
        return appname
    }
    
    func qrStringAppName() -> String {
        return qrStringParam(paramKey: "appname")
    }
    
    func qrStringNonce() -> String {
        return qrStringParam(paramKey: "nonce")
    }
    
    func qrStringSign() -> String {
        return qrStringParam(paramKey: "sign")
    }
    
    func qrStringAddress() -> String {
        return qrStringParam(paramKey: "address")
    }
    
    func checkPayInfo() -> Bool {
        if self.components(separatedBy: "&sign=").count > 1 {
            if let str = self.components(separatedBy: "&sign=").first {
                let sign = str + Dex4DKeys.md5PrivateKey
                if sign.md5() == self.qrStringSign() && self.qrStringSign() != "" {
                    return true
                }
            }
        }
        return false
    }
    func md5String() -> String {
        return (self + Dex4DKeys.md5PrivateKey).md5()
    }
}

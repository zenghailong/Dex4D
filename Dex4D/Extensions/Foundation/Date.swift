//
//  Date.swift
//  Dex4D
//
//  Created by 龙 on 2018/11/14.
//  Copyright © 2018年 龙. All rights reserved.

import Foundation

extension Date {
    
    static func getCurrentTime() -> Int64 {
        let now = Date()
        let timeInterval: TimeInterval = now.timeIntervalSince1970
        return Int64(timeInterval)
    }
    
    static func currentTime() -> String {
        let date = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return timeFormatter.string(from: date)
    }
    
    static func formatterTimeToDate(stringTime: String) -> Date {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dfmatter.date(from: stringTime) ?? Date()
        return date
    }
    
    static func timeStampToString(timeStamp: String) -> String {
        let dfmatter = DateFormatter()
        dfmatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = dfmatter.date(from: timeStamp)
        return dfmatter.string(from: date ?? Date())
    }
}

extension Int {
    // MARK: - Int保留多少位 默认为2
    func keepInt(_ digits:Int = 2) -> String {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = digits
        return String.getString(formatter.string(for: self))
    }
}

extension String {
    /// 获取不为options字符串
    ///
    /// - Returns: 不为options字符串
    static func getString(_ string:String?) -> String {
        if String.isStringNil(string) {
            return ""
        } else {
            return string!
        }
    }
    
    /// 判断字符串是否为空
    ///
    /// - Parameter string: 传入字符串
    /// - Returns: true为nil false不为nil
    static func isStringNil(_ string:String?) -> Bool {
        guard let string = string else { return true }
        if string.count == 0 {
            return true
        } else {
            return false
        }
    }
}

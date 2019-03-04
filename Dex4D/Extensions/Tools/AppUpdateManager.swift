//
//  AppUpdateManager.swift
//  Dex4D
//
//  Created by lax on 2018/11/26.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class AppUpdateManager {
    
    func check(showLast: Bool = false) {
        sessionSimpleDownload { (dict) in
            print(dict)
            if let newVersion = dict["lowest_version"], Bundle.main.appVersion < newVersion {
                print(newVersion)
                UIApplication.shared.windows.first?.rootViewController?.alertMessage(title: "Find new version".localized, message: "", ok: "Upgrade now".localized, completion: {
                    if let str = dict["url"], let url = URL(string: str) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
            } else if let newVersion = dict["version"], Bundle.main.appVersion < newVersion {
                print(newVersion)
                if showLast || !UserDefaults.getBoolValue(for: newVersion) {
                    UIApplication.shared.windows.first?.rootViewController?.alertMessageWithCancel(title: "Find new version".localized, message: "", ok: "Upgrade now".localized, cancel: "Remind me later".localized, completion: {
                        if let str = dict["url"], let url = URL(string: str) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    })
                    UserDefaults.setBoolValue(value: true, key: newVersion)
                }
            } else if showLast {
                UIApplication.shared.windows.first?.rootViewController?.alertMessage(title: "This is the last version".localized, message: "", ok: "OK".localized, completion: nil)
            }
        }
    }
    
    func sessionSimpleDownload(completion: @escaping (Dictionary<String, String>) -> Void) {
        let url = URL(string: "http://106.75.25.3:8089/version/ios/version.json")
        let request = URLRequest(url: url!)
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: request, completionHandler: { (location:URL?, response:URLResponse?, error:Error?) -> Void in
            guard let url = location else { return }
            do {
                let data = try Data(contentsOf: url)
                let jsonData:Any = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
                if let dict = jsonData as? Dictionary<String, String> {
                    DispatchQueue.main.async(execute: {
                        completion(dict)
                    })
                }
            } catch {}
        })
        downloadTask.resume()
    }
}

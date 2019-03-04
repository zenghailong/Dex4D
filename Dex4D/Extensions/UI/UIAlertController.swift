//
//  UIAlertController.swift
//  Dex4D
//
//  Created by 龙 on 2018/10/16.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    static func alertAction(target: UIViewController, title: String, message: String?, sureActionText: String?, cancelActionText: String, sureAction: (() -> Void)?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        if let text = sureActionText {
            let sureAction = UIAlertAction(title: text, style: .default, handler: {
                action in
                sureAction!()
            })
            alertController.addAction(sureAction)
        }
        target.present(alertController, animated: true, completion: nil)
    }
    
    static func alertAction(target: UIViewController, title: String, message: String?, cancelActionText: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: cancelActionText, style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        target.present(alertController, animated: true, completion: nil)
    }
    
}

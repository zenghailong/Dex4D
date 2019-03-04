//
//  FingerManager.swift
//  DAPPBrowser
//
//  Created by ColdChains on 2018/9/18.
//  Copyright © 2018 ColdChains. All rights reserved.
//

import Foundation
import LocalAuthentication

class TouchIdManager: NSObject {
    
    @objc enum TouchIdResult: NSInteger {
        case success             //成功
        case failed              //失败
        case passwordNotSet      //未设置手机密码
        case touchidNotSet       //未设置指纹
        case touchidNotAvailable //不支持指纹
        case systemCancle           //系统取消
        case userCancel           //用户取消
        case inputPassword            //输入密码
    }
    
    static var hasTouchId: Bool {
        if #available(iOS 8.0, OSX 10.12, *) {
            let context = LAContext()
            var error: NSError? = nil
            if(context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)) {
                return true
            }
        }
        return false
    }
    
    static func startFingerUnlock(withtips tips:String, block : @escaping (_ result :TouchIdResult) -> Void) {
        if #available(iOS 8.0, OSX 10.12, *) { //IOS 版本判断 低于版本无需调用
            let context = LAContext()//创建一个上下文对象
            var error: NSError? = nil//捕获异常
            if(context.canEvaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, error: &error)) {//判断当前设备是否支持指纹解锁
                //指纹解锁开始啦
                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason:tips, reply: { (success, error) in
                    if(success) {
                        //进行UI操作
                        print("解锁成功");
                        block(.success)
                    } else {
                        let laerror = error as! LAError
                        switch laerror.code {
                        case LAError.authenticationFailed:
                            print("连续三次输入错误，身份验证失败。")
                            block(.failed)
                            break
                        case LAError.userCancel:
                            print("用户点击取消按钮。")
                            block(.userCancel)
                            break
                        case LAError.userFallback:
                            print("用户点击输入密码。")
                            block(.inputPassword)
                            break
                        case LAError.systemCancel:
                            print("系统取消")
                            block(.systemCancle)
                            break
                        case LAError.passcodeNotSet:
                            print("用户未设置密码")
                            block(.passwordNotSet)
                            break
                        case LAError.touchIDNotAvailable:
                            print("touchID不可用")
                            block(.touchidNotAvailable)
                            break
                        case LAError.touchIDNotEnrolled:
                            print("touchID未设置指纹")
                            block(.touchidNotSet)
                            break
                        default: break
                        }
                    }
                })
            } else {
                print("不支持touchid");
                block(.touchidNotAvailable)
            }
        }
    }
    
}

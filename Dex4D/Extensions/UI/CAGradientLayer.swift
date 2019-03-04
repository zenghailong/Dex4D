//
//  CAGradientLayer.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/11.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

extension UIView {
    
    public func addGradientLayer(frame: CGRect, colors: [CGColor]) {
        layoutIfNeeded()
        removeGradientLayer()
        
        let start = CGPoint(x: 0, y: 0)
        let end = CGPoint(x: 1, y: 1)
        let gradientLayer = CAGradientLayer()
        
        gradientLayer.startPoint = start
        gradientLayer.endPoint = end
        gradientLayer.frame = frame
        gradientLayer.colors = colors
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    public func removeGradientLayer() {
        if let sl = self.layer.sublayers {
            for layer in sl {
                if layer.isKind(of: CAGradientLayer.self) {
                    layer.removeFromSuperlayer()
                }
            }
        }
    }
    
}

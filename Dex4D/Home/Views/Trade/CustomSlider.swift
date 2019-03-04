//
//  CustomSlider.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/16.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class CustomSlider: UISlider {
    
    init() {
        super.init(frame: CGRect())
        self.minimumValue = 0
        self.maximumValue = 100
        self.value = 0
        self.minimumTrackTintColor = Colors.globalColor
        self.maximumTrackTintColor = UIColor(hex: "50505D")
        self.setThumbImage(R.image.icon_slider(), for: .normal)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 14, width: self.frame.size.width, height: 6)
    }

    override func thumbRect(forBounds bounds: CGRect, trackRect rect: CGRect, value: Float) -> CGRect {
        var trect = rect
        trect.origin.x -= 5
        trect.size.width += 10
        var srect = super.thumbRect(forBounds: bounds, trackRect: trect, value: value)
        srect.origin.y += 2
        return srect
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
    
}

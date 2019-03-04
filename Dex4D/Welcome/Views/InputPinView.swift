//
//  InputPinView.swift
//  Dex4D
//
//  Created by zeng hai long on 14/10/18.
//  Copyright © 2018年 龙. All rights reserved.
//

import UIKit

class InputPinView: UIView {
    
    let circlePointSize: CGFloat = 10
    
    let viewModel: GeneratePasswordViewModel!
    
    var showPointCount: Int = 0
    
    var circleArray: [UIView] = []
    
    var circlePointArr: [UIView] = []
    
    init(frame: CGRect, viewModel: GeneratePasswordViewModel) {
        self.viewModel = viewModel
        super.init(frame: frame)
        addCircleView()
    }
    
    fileprivate func addCircleView() {
        for _ in 0..<viewModel.circleCount {
            let circleBackgroundView = UIView()
            circleBackgroundView.backgroundColor = UIColor(hex: "19191F")
            circleBackgroundView.layer.cornerRadius = viewModel.circleSize / 2
            
            let circlePoint = UIView(frame: CGRect(x: 0, y: 0, width: circlePointSize, height: circlePointSize))
            circlePoint.center = CGPoint(x: viewModel.circleSize / 2, y: viewModel.circleSize / 2)
            circlePoint.backgroundColor = UIColor.white
            circlePoint.layer.cornerRadius = circlePointSize / 2
            circlePoint.isHidden = true
            
            addSubview(circleBackgroundView)
            circleBackgroundView.addSubview(circlePoint)
            circleArray.append(circleBackgroundView)
            circlePointArr.append(circlePoint)
        }
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var circleX: CGFloat = 0
        let padding = (frame.size.width - CGFloat(viewModel.circleCount) * viewModel.circleSize) / CGFloat(viewModel.circleCount - 1)
        for (index, point) in circleArray.enumerated() {
            circleX = (padding + viewModel.circleSize) * CGFloat(index)
            point.frame = CGRect(x: circleX, y: 0, width: viewModel.circleSize, height: viewModel.circleSize)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension InputPinView {
    
    func inputNumber() {
        guard showPointCount < viewModel.circleCount else {
            return
        }
        let point = circlePointArr[showPointCount]
        point.isHidden = false
        showPointCount += 1
    }
    
    func deleteNumber() {
        guard showPointCount > 0 else {
            return
        }
        let point = circlePointArr[showPointCount - 1]
        point.isHidden = true
        showPointCount -= 1
    }
    
    func deleteAll() {
        while showPointCount > 0 {
            let point = circlePointArr[showPointCount - 1]
            point.isHidden = true
            showPointCount -= 1
        }
    }
    
}

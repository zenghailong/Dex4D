//
//  SwapLockView.swift
//  Dex4D
//
//  Created by ColdChains on 2018/10/17.
//  Copyright © 2018 龙. All rights reserved.
//

import UIKit

class SwapLockView: UIView {
    
    struct TimerName {
        let advisorTimer = "AdvisorTimer"
        let sunDownTimer = "SunDownTimer"
    }
    
    private lazy var tipsLabel: UILabel = {
        let label = UILabel()
        label.textColor = Colors.textTips
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.defaultFont(size: 12)
        return label
    }()
    
    private lazy var tipsButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = Colors.buttonInvalid
        button.setTitle("Confim".localized, for: .normal)
        button.setTitleColor(Colors.buttonInvalidText, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    let dexToken: DexTokenObject
    
    let timer = TimerHelper.shared
    
    init(dexToken: DexTokenObject) {
        self.dexToken = dexToken
        super.init(frame: CGRect())
        self.addSubview(tipsLabel)
        tipsLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.snp.centerY).offset(-30)
            make.centerX.equalToSuperview()
        }
        
        switch dexToken.tokenState {
        case .advisor:
            timer.scheduledDispatchTimer(WithTimerName: TimerName().advisorTimer, timeInterval: 1, queue: .main, repeats: true) {[weak self] in
                self?.advisorTimerCount()
            }
        case .new:
            tipsLabel.text = "New coin, Swap option is not available".localized
        case .regular:
            tipsLabel.text = "Not available, \nplease go to “Me > Authority > Swap“ \nto see more details".localized
        case .sunDown:
            timer.scheduledDispatchTimer(WithTimerName: TimerName().sunDownTimer, timeInterval: 1, queue: .main, repeats: true) {[weak self] in
                self?.sunDownTimerCount()
            }
        case .delist:
            tipsLabel.text = "Delist. Only history price provided".localized
        }
    }
    
    private func advisorTimerCount() {
        refreshTime(endTime: dexToken.ambassador_end, timerName: TimerName().advisorTimer, state: .advisor)
    }
    
    private func sunDownTimerCount() {
         refreshTime(endTime: dexToken.offline_time, timerName: TimerName().sunDownTimer, state: .sunDown)
    }
    
    private func refreshTime(endTime: String, timerName: String, state: TokenState) {
        let endDate = Date.formatterTimeToDate(stringTime: endTime)
        let nowDate = Date()
        let calendar = NSCalendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: nowDate, to: endDate)
        guard let hour = components.hour,
            let minute = components.minute,
            let second = components.second else { return }
        
        if hour < 0 || minute < 0 || second < 0  {
            timer.cancleTimer(WithTimerName: timerName)
            if state == .advisor {
               tipsLabel.text = String(format: "Advisor tips".localized, "00:00:00")
            }
            if state == .sunDown {
                tipsLabel.text = String(format: "Sun down tips".localized, "00:00:00")
            }
        } else {
            if state == .advisor {
                tipsLabel.text = String(format: "Advisor tips".localized, "\(hour.keepInt()):\(minute.keepInt()):\(second.keepInt())")
            }
            if state == .sunDown {
                tipsLabel.text = String(format: "Sun down tips".localized, "\(hour.keepInt()):\(minute.keepInt()):\(second.keepInt())")
            }
        }
    }
    
    deinit {
        timer.cancleTimer(WithTimerName: TimerName().advisorTimer)
        timer.cancleTimer(WithTimerName: TimerName().sunDownTimer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  QuickTimer.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/15.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import AVFoundation
import UIKit

class quickTimer : NSObject{
    private var session = AVAudioSession.sharedInstance()
    private let notification = UILocalNotification()
    private var soundPlayer:AVAudioPlayer?
    private var timer: Timer?
    
    var timerLabel = "00:00"
    var timerAccessibilityLabel = "0" + NSLocalizedString("Minutes", comment: "Minutes") + "0" + NSLocalizedString("Seconds", comment: "Seconds")
    var aimLabel = ""
    var surplusTime = 0
    var timing = false
    
    private let nowCalendar = Calendar.current
    
    func addTime(_ length:Int) { //加时（分为单位）
        if timing {
            let second = surplusTime % 60
            if second != 0{
                surplusTime += 60 - second
            }
            surplusTime += length * 60
            timer?.invalidate()
            timer = nil
            updateDisplay()
        } else {
            surplusTime += length * 60
        }
        start()
    }
    
    func timerToOClock() {
        let dateComponents = (nowCalendar as NSCalendar).components([NSCalendar.Unit.hour, NSCalendar.Unit.minute, NSCalendar.Unit.second, NSCalendar.Unit.nanosecond], from: Date())
        stop(false)
        let length = (59 - dateComponents.minute!) * 60 + (60 - dateComponents.second!)
        surplusTime += length
        start()
    }
    
    func minusTime(_ length:Int) {
        if timing {
            let second = surplusTime % 60
            if second != 0{
                surplusTime += 60 - second
            }
            surplusTime -= length * 60
            if surplusTime <= 0 {
                surplusTime = 0
                stop(true)
            }
            timer?.invalidate()
            timer = nil
            updateDisplay()
            start()
        }
    }
    
    private func start() {
        if surplusTime <= 0 {
            stop(true)
            surplusTime  = 0
        } else {
            timing = true
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(quickTimer.updateTimer), userInfo: nil, repeats: true)
        }
        updateDisplay()
    }
    
    func stop(_ withSound:Bool) {
        if timing {
            timer?.invalidate()
            timer = nil
            if withSound {
                pomodoroTimer.playSound(0)
            }
            timing = false
            surplusTime = 0
            updateDisplay()
        }
    }
    
    @objc private func updateTimer() {
        if pomodoroTimer.soundPlayer?.isPlaying != true {
            pomodoroTimer.playSound(2)
        }
        surplusTime -= 1
        updateDisplay()
        if surplusTime == 0 {
            if UIApplication.shared.applicationState == UIApplicationState.background {
                notification.alertBody = NSLocalizedString("Time up.", comment: "Time up.")
                notification.alertAction = NSLocalizedString("open", comment: "open")
                notification.category = "TODO_CATEGORY"
                UIApplication.shared.scheduleLocalNotification(notification)
            }
            stop(true)
        }
    }
    
    private func updateDisplay(){
        //生成当前时间的文本表示
        var minute = "\((surplusTime - (surplusTime % 60)) / 60)"
        var second = "\(surplusTime % 60)"
        var hour = "0"
        timerAccessibilityLabel = minute + NSLocalizedString("Minutes", comment: "Minutes") + second + NSLocalizedString("Seconds", comment: "Seconds")
        if surplusTime % 60 < 10 {
            second = "0" + second
        }
        if (surplusTime - (surplusTime % 60)) / 60 < 10 {
            minute = "0" + minute
        }
        if Int(minute) > 60 {
            hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            timerAccessibilityLabel = hour + NSLocalizedString("Hours", comment: "Hours") + minute + NSLocalizedString("Minutes", comment: "Minutes") + second + NSLocalizedString("Seconds", comment: "Seconds")
            if Int(hour) < 10 {
                hour = "0" + hour
            }
            if Int(minute) < 10 {
                minute = "0" + minute
            }
            
            timerLabel = hour + ":" + minute
        } else {
            timerLabel = minute + ":" + second
        }
        var adcomps = DateComponents()
        adcomps.hour = Int(hour)!
        adcomps.minute = Int(minute)!
        adcomps.second = Int(second)!
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        let newDate =  (nowCalendar as NSCalendar).date(byAdding: adcomps, to: Date(), options: .matchNextTimePreservingSmallerUnits)
        aimLabel = formatter.string(from: newDate!)
    }
    
    
}

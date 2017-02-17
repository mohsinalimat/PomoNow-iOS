//
//  Pomodoro.swift
//  PomodoroTimer
//
//  Created by Megabits on 15/9/16.
//  Copyright (c) 2015年 ScrewBox. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import UserNotifications

class pomodoro : NSObject{
    
    private var session = AVAudioSession.sharedInstance()
    var soundPlayer:AVAudioPlayer?
    
    var pomoMode = 0
    var pomoTime = 1500 { didSet { //预设番茄钟时间
        dataManagement.setDefaults ("pomo.pomoTime",value: pomoTime as AnyObject)
        updateDisplay()
        } }
    var breakTime = 300 { didSet { //预设休息时间
        dataManagement.setDefaults ("pomo.breakTime",value: breakTime as AnyObject)
        updateDisplay()
        } }
    var longBreakTime = 1500 { didSet { //预设长休息时间
        dataManagement.setDefaults ("pomo.longBreakTime",value: longBreakTime as AnyObject)
        updateDisplay()
        } }
    
    var nowTime = 0
    private var localCount = 0
    
    var process:Float = 0
    var timerLabel = "00:00"
    var timerAccessibilityLabel = "0" + NSLocalizedString("Minutes", comment: "Minutes") + "0" + NSLocalizedString("Seconds", comment: "Seconds")
    
    var longBreakEnable = false { //是否开启连续计时
        didSet{
            dataManagement.setDefaults ("pomo.longBreakEnable",value: longBreakEnable as AnyObject)
            if !longBreakEnable {
                localCount = 0
            }
        }
    }
    
    var enableTimerSound = true { didSet { dataManagement.setDefaults ("pomo.enableTimerSound",value: enableTimerSound as AnyObject)}}
    var enableAlarmSound = true { didSet { dataManagement.setDefaults ("pomo.enableAlarmSound",value: enableAlarmSound as AnyObject)}}
    
    var longBreakCount = 4 { didSet { dataManagement.setDefaults ("pomo.longBreakCount",value: longBreakCount as AnyObject) } } //几个循环后进入长休息
    
    private var timer: Timer? //主计时器
    
    private var isDebug = false
    
    override init() {
        super.init()
        if dataManagement.getDefaults("pomo.pomoTime") != nil {  //存储设置
            pomoTime = dataManagement.getDefaults("pomo.pomoTime") as? Int ?? 1500
            breakTime = dataManagement.getDefaults("pomo.breakTime") as? Int ?? 300
            longBreakTime = dataManagement.getDefaults("pomo.longBreakTime") as? Int ?? 1500
            longBreakCount = dataManagement.getDefaults("pomo.longBreakCount") as? Int ?? 4
            longBreakEnable = dataManagement.getDefaults("pomo.longBreakEnable") as? Bool ?? false
            enableTimerSound = dataManagement.getDefaults("pomo.enableTimerSound") as? Bool ?? true
            enableAlarmSound = dataManagement.getDefaults("pomo.enableAlarmSound") as? Bool ?? true
        } else {
            dataManagement.setDefaults ("pomo.pomoTime",value: pomoTime as AnyObject)
            dataManagement.setDefaults ("pomo.breakTime",value: breakTime as AnyObject)
            dataManagement.setDefaults ("pomo.longBreakTime",value: longBreakTime as AnyObject)
            dataManagement.setDefaults ("pomo.longBreakCount",value: longBreakCount as AnyObject)
            dataManagement.setDefaults ("pomo.longBreakEnable",value: longBreakEnable as AnyObject)
            dataManagement.setDefaults ("pomo.enableTimerSound",value: enableTimerSound as AnyObject)
            dataManagement.setDefaults ("pomo.enableAlarmSound",value: enableAlarmSound as AnyObject)
        }
        
        updateDisplay()
        
        //声音后台播放
        do {try session.setCategory(AVAudioSessionCategoryPlayback,with:AVAudioSessionCategoryOptions.mixWithOthers)} catch _ { }
        do {try session.setActive(true)} catch _ { }
        
//        isDebug = true //调试模式
    }
    
    @objc private func updateTimer(_ timer:Timer) { //确定计时状态和调整时间
        if nowTime <= 0{
            stopTimer()
            if pomoMode == 1 {
                if longBreakEnable {
                    if localCount == longBreakCount - 1 {
                        pomoMode = 3
                        nowTime = longBreakTime
                    } else {
                        pomoMode += 1
                        nowTime = breakTime
                    }
                } else {
                    pomoMode += 1
                    nowTime = breakTime
                }
                playSound(0)
                breakStart()
                pushNotification(0)
            } else if pomoMode == 2 {
                if longBreakEnable {
                    pushNotification(2)
                    localCount += 1
                    pomoMode = 0
                    start()
                } else {
                    pushNotification(1)
                    finishFirstPomodoro = true
                    NotificationCenter.default.post(name: Notification.Name(rawValue: "PomodoroStopped"), object: self, userInfo: nil)
                    pomoMode = 0
                }
                playSound(0)
            } else if pomoMode == 3 {
                pomoMode = 0
                localCount = 0
                playSound(0)
                start()
                pushNotification(2)
            }
        } else {
            if soundPlayer?.isPlaying != true {
                if pomoMode == 2 {
                    playSound(3)
                } else {
                    playSound(2)
                }
            }
            if isDebug {
                nowTime -= 100
            } else {
                nowTime -= 1
            }
        }
        updateDisplay()
    }
    
    func pushNotification(_ notificationIndex:Int) {
        if notificationIndex == 0 { //完成数加一
            NotificationCenter.default.post(name: Notification.Name(rawValue: "needUpdateData"), object: self, userInfo: nil)
        }
        
        if UIApplication.shared.applicationState == UIApplicationState.background {
            let currentTaskString = ""
            if #available(iOS 10.0, *) {
                let notification = UNMutableNotificationContent()
                switch notificationIndex {
                case 0:
                    if currentTaskString != "" {
                        notification.body = currentTaskString
                    } else {
                        notification.body = NSLocalizedString("Take a break.", comment: "Take a break.")
                    }
                    notification.title = NSLocalizedString("Work Complete.", comment: "Work Complete.")
                case 1:
                    if currentTaskString != "" {
                        notification.body = currentTaskString
                    } else {
                        notification.body = NSLocalizedString("Great!", comment: "Great!")
                    }
                    notification.title = NSLocalizedString("Pomodoro Complete.", comment: "Pomodoro Complete.")
                case 2:
                    notification.body = NSLocalizedString("Time to work!", comment: "Time to work!")
                    notification.title = NSLocalizedString("Break Complete.", comment: "Break Complete.")
                default:break
                }
                let request = UNNotificationRequest(identifier: "com.JinyuMeng.pomodoro", content: notification, trigger: nil)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
            } else {
                let notification = UILocalNotification()
                switch notificationIndex {
                case 0:
                    if currentTaskString != "" {
                        notification.alertBody = currentTaskString
                    } else {
                        notification.alertBody = NSLocalizedString("Take a break.", comment: "Take a break.")
                    }
                    notification.alertTitle = NSLocalizedString("Work Complete.", comment: "Work Complete.")
                case 1:
                    if currentTaskString != "" {
                        notification.alertBody = currentTaskString
                    } else {
                        notification.alertBody = NSLocalizedString("Great!", comment: "Great!")
                    }
                    notification.alertTitle = NSLocalizedString("Pomodoro Complete.", comment: "Pomodoro Complete.")
                case 2:
                    notification.alertBody = NSLocalizedString("Time to work!", comment: "Time to work!")
                    notification.alertTitle = NSLocalizedString("Break Complete.", comment: "Break Complete.")
                default:break
                }
                UIApplication.shared.applicationIconBadgeNumber = 1
                UIApplication.shared.applicationIconBadgeNumber = 0
                UIApplication.shared.cancelAllLocalNotifications()
                notification.category = "com.JinyuMeng.pomodoro"
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        }
    }
    
    private func updateDisplay() {
        //生成百分比形式的进度
        switch pomoMode {
        case 1:
            process = Float(nowTime) / Float(pomoTime) * 100
        case 2:
            process = Float(nowTime) / Float(breakTime) * 100
        case 3:
            process = Float(nowTime) / Float(longBreakTime) * 100
        default:
            process = 0
        }
        //生成当前时间的文本表示
        var nowUse = 0
        if pomoMode == 0 {
            nowUse = pomoTime
        } else {
            nowUse = nowTime
        }
        var minute = "\((nowUse - (nowUse % 60)) / 60)"
        var second = "\(nowUse % 60)"
        timerAccessibilityLabel = minute + NSLocalizedString("Minutes", comment: "Minutes") + second + NSLocalizedString("Seconds", comment: "Seconds")
        if nowUse % 60 < 10 {
            second = "0" + second
        }
        if (nowUse - (nowUse % 60)) / 60 < 10 {
            minute = "0" + minute
        }
        if Int(minute) > 60 {
            var hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
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
    }
    
    func getStringOfTime(_ select:Int) -> (count:Int,hour:String,min:String,sec:String) { //输出想要获得的时间的文本表示
        var resultCount = 0
        var nowUse = 0
        var timerLabelMin = "0"
        var timerLabelSec = "0"
        var timerLabelHour = "0"
        switch select {
        case 0:nowUse = pomoTime
        case 1:nowUse = breakTime
        case 2:nowUse = longBreakTime
        default:nowUse = pomoTime
        }
        var minute = "\((nowUse - (nowUse % 60)) / 60)"
        let second = "\(nowUse % 60)"
        timerLabelSec = second
        resultCount += 1
        timerLabelMin = minute
        if nowUse >= 60 {
            resultCount += 1
        }
        if Int(minute) > 60 {
            let hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            timerLabelMin = minute
            timerLabelHour = hour
            resultCount += 1
            
        }
        return (resultCount,timerLabelHour,timerLabelMin,timerLabelSec)
    }
    
    func start() {
        if pomoMode == 0 {
            pomoMode = 1
            nowTime = pomoTime
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "PomodoroStarted"), object: self, userInfo: nil)
            
            //取消 Apple watch 建立的推送通知
            if #available(iOS 10.0, *) {
                UNUserNotificationCenter.current().removeAllDeliveredNotifications()
            } else {
                let application = UIApplication.shared
                application.applicationIconBadgeNumber = 1
                application.applicationIconBadgeNumber = 0
                application.cancelAllLocalNotifications()
            }

        }
    }
    
    private func breakStart() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
    }
    
    func stop() {
        if pomoMode != 0 {
            playSound(0)
        }
        stopTimer()
        NotificationCenter.default.post(name: Notification.Name(rawValue: "PomodoroStopped"), object: self, userInfo: nil)
        pomoMode = 0
        nowTime = 0
        localCount = 0
        updateDisplay()
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
        process = 0
    }
    func playSound(_ soundIndex: Int) {
        let startSoundPath = Bundle.main.path(forResource: "Start", ofType: "mp3")
        let stopSoundPath = Bundle.main.path(forResource: "Stop", ofType: "mp3")
        let pomoingSoundPath = Bundle.main.path(forResource: "Pomoing", ofType: "mp3")
        
        let startSoundUrl = URL(fileURLWithPath: startSoundPath!)
        let stopSoundUrl = URL(fileURLWithPath: stopSoundPath!)
        let pomoingSoundUrl = URL(fileURLWithPath: pomoingSoundPath!)
        
        switch soundIndex {
        case 0:
            stopSound()
            if enableAlarmSound {
                do {soundPlayer = try AVAudioPlayer(contentsOf: stopSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = 0
                soundPlayer!.volume = 1
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            }
            
        case 1:
            func playSound() {
                stopSound()
                do {soundPlayer = try AVAudioPlayer(contentsOf: startSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 1
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            }
            if enableAlarmSound {
                if soundPlayer != nil {
                    if soundPlayer!.isPlaying {
                        let time: TimeInterval = 0.1 //避开停止提示音
                        let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delay) {
                                playSound()
                        }
                    } else {
                        playSound()
                    }
                } else {
                    playSound()
                }
            }
        case 2:
            stopSound()
            if enableTimerSound {
                do {soundPlayer = try AVAudioPlayer(contentsOf: pomoingSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0.2
            } else {
                do {soundPlayer = try AVAudioPlayer(contentsOf: pomoingSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0
            }
            soundPlayer!.prepareToPlay()
            soundPlayer!.play()
        case 3:
            stopSound()
            if enableTimerSound {
                do {soundPlayer = try AVAudioPlayer(contentsOf: pomoingSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0.02
            } else {
                do {soundPlayer = try AVAudioPlayer(contentsOf: pomoingSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0
            }
            soundPlayer!.prepareToPlay()
            soundPlayer!.play()
        default:
            if soundPlayer != nil {
                soundPlayer!.stop()
            }
        }
    }
    func stopSound() {
        if soundPlayer != nil {
            soundPlayer!.stop()
            soundPlayer = nil
        }
    }
}

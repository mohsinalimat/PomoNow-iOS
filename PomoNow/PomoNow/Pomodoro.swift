//
//  Pomodoro.swift
//  PomoNow
//
//  Created by Megabits on 15/9/16.
//  Copyright (c) 2015年 Jinyu Meng. All rights reserved.
//

import AVFoundation
import UIKit

class pomodoro : NSObject{
    
    fileprivate let defaults = UserDefaults.standard
    
    fileprivate var session = AVAudioSession.sharedInstance()
    let notification = UILocalNotification()
    var soundPlayer:AVAudioPlayer?
    
    var pomoMode = 0
    var finishOne = false
    var pomoTime = 1500 { didSet {
        setDefaults ("pomo.pomoTime",value: pomoTime as AnyObject)
        updateDisplay()
        } }
    var breakTime = 300 { didSet {
        setDefaults ("pomo.breakTime",value: breakTime as AnyObject)
        updateDisplay()
        } }
    var longBreakTime = 1500 { didSet {
        setDefaults ("pomo.longBreakTime",value: longBreakTime as AnyObject)
        updateDisplay()
        } }
    
    var nowTime = 0
    var localCount = 0
    
    var process:Float = 0
    var timerLabel = "00:00"
    var timerLabelMin = "0"
    var timerLabelSec = "0"
    var timerLabelHour = "0"
    
    var longBreakEnable = false { //是否开启连续计时
        didSet{
            setDefaults ("pomo.longBreakEnable",value: longBreakEnable as AnyObject)
            if !longBreakEnable {
                localCount = 0
            }
        }
    }
    
    var enableTimerSound = true { didSet { setDefaults ("pomo.enableTimerSound",value: enableTimerSound as AnyObject)}}
    var enableAlarmSound = true { didSet { setDefaults ("pomo.enableAlarmSound",value: enableAlarmSound as AnyObject)}}

    var longBreakCount = 4 { didSet { setDefaults ("pomo.longBreakCount",value: longBreakCount as AnyObject) } } //几个循环后进入长休息
    
    fileprivate var timer: Timer?
    fileprivate var isDebug = false
    
    override init() {
        super.init()
        if getDefaults("pomo.pomoTime") != nil {  //存储设置
            pomoTime = getDefaults("pomo.pomoTime") as? Int ?? 1500
            breakTime = getDefaults("pomo.breakTime") as? Int ?? 300
            longBreakTime = getDefaults("pomo.longBreakTime") as? Int ?? 1500
            longBreakCount = getDefaults("pomo.longBreakCount") as? Int ?? 4
            longBreakEnable = getDefaults("pomo.longBreakEnable") as? Bool ?? false
            enableTimerSound = getDefaults("pomo.enableTimerSound") as? Bool ?? true
            enableAlarmSound = getDefaults("pomo.enableAlarmSound") as? Bool ?? true
        } else {
            setDefaults ("pomo.pomoTime",value: pomoTime as AnyObject)
            setDefaults ("pomo.breakTime",value: breakTime as AnyObject)
            setDefaults ("pomo.longBreakTime",value: longBreakTime as AnyObject)
            setDefaults ("pomo.longBreakCount",value: longBreakCount as AnyObject)
            setDefaults ("pomo.longBreakEnable",value: longBreakEnable as AnyObject)
            setDefaults ("pomo.enableTimerSound",value: enableTimerSound as AnyObject)
            setDefaults ("pomo.enableAlarmSound",value: enableAlarmSound as AnyObject)
        }
        
        updateDisplay()
        
        //声音后台播放
        do {try session.setCategory(AVAudioSessionCategoryPlayback,with:AVAudioSessionCategoryOptions.mixWithOthers)} catch _ { }
        do {try session.setActive(true)} catch _ { }
        
//        isDebug = true //调试模式
    }
    
    @objc func updateTimer(_ timer:Timer) { //确定计时状态和调整时间
        if nowTime <= 0{
            stopTimer()
            if pomoMode == 1 {
                if longBreakEnable {
                    if localCount == longBreakCount - 1 {
                        pomoMode = 3
                        nowTime = longBreakTime
                        playSound(0)
                        longBreakStart()
                    } else {
                        pomoMode += 1
                        nowTime = breakTime
                        playSound(0)
                        breakStart()
                    }
                } else {
                    pomoMode += 1
                    nowTime = breakTime
                    playSound(0)
                    breakStart()
                }
                notification.alertBody = NSLocalizedString("Take a break.", comment: "Take a break.")
                notification.alertAction = NSLocalizedString("open", comment: "open")
                notification.category = "TODO_CATEGORY"
                UIApplication.shared.scheduleLocalNotification(notification)
            } else if pomoMode == 2 {
                if longBreakEnable {
                    notification.alertBody = NSLocalizedString("Time to work!", comment: "Time to work!")
                    localCount += 1
                    pomoMode = 0
                    start()
                } else {
                    notification.alertBody = NSLocalizedString("Focus Complete!", comment: "Focus Complete!")
                    pomoMode = 0
                }
                notification.alertAction = NSLocalizedString("open", comment: "open")
                notification.category = "TODO_CATEGORY"
                UIApplication.shared.scheduleLocalNotification(notification)
                playSound(0)
                finishOne = true
            } else if pomoMode == 3 {
                pomoMode = 0
                localCount = 0
                start()
                playSound(0)
                notification.alertBody = NSLocalizedString("Time to work!", comment: "Time to work!")
                notification.alertAction = NSLocalizedString("open", comment: "open")
                notification.category = "TODO_CATEGORY"
                UIApplication.shared.scheduleLocalNotification(notification)
            }
        } else {
            if soundPlayer?.isPlaying != true {
                if pomoMode == 2 {
                    playSound(10)
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
    
    fileprivate func updateDisplay() {
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
        if nowUse % 60 < 10 {
            second = "0" + second
        }
        if (nowUse - (nowUse % 60)) / 60 < 10 {
            minute = "0" + minute
        }
        if Int(minute)! > 60 {
            var hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            if Int(hour)! < 10 {
                hour = "0" + hour
            }
            if Int(minute)! < 10 {
                minute = "0" + minute
            }
            
            timerLabel = hour + ":" + minute
        } else {
            timerLabel = minute + ":" + second
        }
    }
    
    func getStringOfTime(_ select:Int) -> Int{ //输出想要获得的时间的文本表示
        var resultCount = 0
        var nowUse = 0
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
        if Int(minute)! > 60 {
            let hour = "\((Int(minute)! - (Int(minute)! % 60)) / 60)"
            minute = "\(Int(minute)! % 60)"
            timerLabelMin = minute
            timerLabelHour = hour
            resultCount += 1
            
        }
        return resultCount
    }
    
    func start() {
        if pomoMode == 0 {
            pomoMode = 1
            nowTime = pomoTime
            timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
        }
    }
    
    fileprivate func breakStart() {
        if withTask{
            for i in 0...task.count - 1 {
                if task[i][3] == "1" {
                    if Int(task[i][2])! < 100 {
                        task[i][2] = String(Int(task[i][2])! + 1)
                    }
                }
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
        taskChanged = true
    }
    
    fileprivate func longBreakStart() {
        if withTask{
            for i in 0...task.count - 1 {
                if task[i][3] == "1" {
                    if Int(task[i][2])! < 100 {
                        task[i][2] = String(Int(task[i][2])! + 1)
                    }
                }
            }
        }
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(pomodoro.updateTimer(_:)), userInfo: nil, repeats: true)
        taskChanged = true
    }
    
    func stop() {
        if pomoMode != 0 {
            playSound(0)
        }
        stopTimer()
        pomoMode = 0
        nowTime = 0
        localCount = 0
        updateDisplay()
    }
    
    fileprivate func getDefaults (_ key: String) -> AnyObject? {
        if key != "" {
            return defaults.object(forKey: key) as AnyObject
        } else {
            return nil
        }
    }
    
    fileprivate func setDefaults (_ key: String,value: AnyObject) {
        if key != "" {
            defaults.set(value,forKey: key)
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        process = 0
    }
    
    func playSound(_ soundIndex: Int) {
        let startSoundPath = Bundle.main.path(forResource: "Start", ofType: "mp3")
        let stopSoundPath = Bundle.main.path(forResource: "Stop", ofType: "mp3")
        let pomoingSoundPath = Bundle.main.path(forResource: "Pomoing", ofType: "mp3")
        let muteSoundPath = Bundle.main.path(forResource: "Mute", ofType: "mp3")
        
        let startSoundUrl = URL(fileURLWithPath: startSoundPath!)
        let stopSoundUrl = URL(fileURLWithPath: stopSoundPath!)
        let pomoingSoundUrl = URL(fileURLWithPath: pomoingSoundPath!)
        let muteSoundUrl = URL(fileURLWithPath: muteSoundPath!)
        
        switch soundIndex {
        case 0:
            stopSound()
            if enableAlarmSound {
                do {soundPlayer = try AVAudioPlayer(contentsOf: stopSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = 0
                soundPlayer!.volume = 1
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            } else {
                do {soundPlayer = try AVAudioPlayer(contentsOf: muteSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = 0
                soundPlayer!.volume = 0.2
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
                        let time: TimeInterval = 0.4
                        let delay = DispatchTime.now() + Double(Int64(time * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                        DispatchQueue.main.asyncAfter(deadline: delay) {
                            if !needStop {
                                playSound()
                            } else {
                                needStop = false
                            }
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
                soundPlayer!.prepareToPlay()
                soundPlayer!.play() 
            } else {
                do {soundPlayer = try AVAudioPlayer(contentsOf: muteSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0.2
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            }
        case 10:
            stopSound()
            if enableTimerSound {
                do {soundPlayer = try AVAudioPlayer(contentsOf: pomoingSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0.02
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            } else {
                do {soundPlayer = try AVAudioPlayer(contentsOf: muteSoundUrl)} catch _ { }
                soundPlayer!.numberOfLoops = -1
                soundPlayer!.volume = 0.1
                soundPlayer!.prepareToPlay()
                soundPlayer!.play()
            }
        default:
            if soundPlayer != nil {
                soundPlayer!.stop()
            }
        }
    }
    func stopSound() {
        if soundPlayer != nil {
            soundPlayer!.stop()
        }
    }
}

//  Defaults name space :
//      pomo.pomoTime
//          .breakTime
//          .longBreakTime

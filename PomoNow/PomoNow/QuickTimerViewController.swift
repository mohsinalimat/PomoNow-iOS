//
//  QuickTimerViewController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/7.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit
import AVFoundation

class QuickTimerViewController: UIViewController {

    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var timePlus1: UIButton!
    @IBOutlet weak var timeMinus1: UIButton!
    @IBOutlet weak var timePlus2: UIButton!
    @IBOutlet weak var timePlus5: UIButton!
    @IBOutlet weak var timePlus10: UIButton!
    @IBOutlet weak var timePlus30: UIButton!
    @IBOutlet weak var timePlus1h: UIButton!
    @IBOutlet weak var timeToOClock: UIButton!
    @IBOutlet weak var stop: UIButton!
    @IBOutlet weak var aStopView: UIView!
    @IBOutlet weak var taskBackground: UIView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!

    private var session = AVAudioSession.sharedInstance()
    var soundPlayer:AVAudioPlayer?
    var background : CAGradientLayer? = nil
    var timer: Timer?
    
    @IBAction func changeTime(_ sender: UIButton) {
        buttonSound()
        switch sender.titleLabel!.text! {
        case "＋":
            quickTimerClass.addTime(1)
        case "－":
            quickTimerClass.minusTime(1)
        case "  +2  ":
            quickTimerClass.addTime(2)
        case "  +5  ":
            quickTimerClass.addTime(5)
        case " +10 ":
            quickTimerClass.addTime(10)
        case " +30 ":
            quickTimerClass.addTime(30)
        case NSLocalizedString(" +1h ",comment:" +1h "):
            quickTimerClass.addTime(60)
        case NSLocalizedString("  o'clock ",comment:"  o'clock "):
            quickTimerClass.timerToOClock()
        default:
            break
        }
        if quickTimerClass.timing {
            stop.isEnabled = true
            timeMinus1.isEnabled = true
        }
        timing()
    }
    
    @IBAction func ipadStop(_ sender: UITapGestureRecognizer) {
        if isiPad { //在iPad上不使用Stop按钮
            quickTimerClass.stop(true)
            timing()
        }
    }
    @IBAction func iphonrStop(_ sender: AnyObject) {
        quickTimerClass.stop(true)
        stop.isEnabled = false
        timeMinus1.isEnabled = false
        timing()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(QuickTimerViewController.timing), userInfo: nil, repeats: true)
        
        background = turquoiseColor() //设置背景
        background!.frame.size.height = view.bounds.height
        background!.frame.size.width = view.bounds.width
        view.layer.insertSublayer(background!, at: 0)
        
        if isiPad { //在iPad上不使用Stop按钮
            stop.isHidden = true
        } else {
            aStopView.isHidden = true
        }
        
        if !quickTimerClass.timing {
            stop.isEnabled = false
            timeMinus1.isEnabled = false
        }
        
        //声音后台播放
        do {try session.setCategory(AVAudioSessionCategoryPlayback,with:AVAudioSessionCategoryOptions.mixWithOthers)} catch _ { }
        do {try session.setActive(true)} catch _ { }
        
        hintLabel.text = NSLocalizedString("Quick timer mode",comment:"Quick timer mode")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        taskLabel.text = NSLocalizedString("Current time:",comment:"Current time:") + formatter.string(from: Date())
        
        //无障碍信息
        timeLabel.accessibilityLabel = quickTimerClass.timerAccessibilityLabel
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
        setStyleMode()
    }
    
    func timing() {
        timeLabel.text = quickTimerClass.timerLabel
        timeLabel.accessibilityLabel = quickTimerClass.timerAccessibilityLabel
        if quickTimerClass.timing {
            if isiPad {
                hintLabel.text = NSLocalizedString("Tap anywhere to stop", comment:"Tap anywhere to stop")
            }
            taskLabel.text = NSLocalizedString("Target time:",comment:"Target time:") + quickTimerClass.aimLabel
        } else {
            hintLabel.text = NSLocalizedString("Quick timer mode",comment:"Quick timer mode")
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            taskLabel.text = NSLocalizedString("Current time:",comment:"Current time:") + formatter.string(from: Date())
            stop.isEnabled = false
            timeMinus1.isEnabled = false
        }
    }
    
    func setStyleMode() { //UI风格变换
        var borderColor = UIColor.white.cgColor
        let tapColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.5)
        var backColor = UIColor.clear
        var textColor = UIColor.white
        
        if isDarkMode {
            background!.isHidden = true
            view.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            timeLabel.textColor = UIColor(red: 0.949, green: 0.3373, blue: 0.2824, alpha: 1.0)
            timePlus1.setTitleColor(UIColor(red: 0.949, green: 0.3373, blue: 0.2824, alpha: 1.0), for: UIControlState())
            timeMinus1.setTitleColor(UIColor(red: 0.949, green: 0.3373, blue: 0.2824, alpha: 1.0), for: UIControlState())
            taskBackground.backgroundColor = UIColor(red: 0.0392, green: 0.0392, blue: 0.0392, alpha: 1.0)
            hintLabel.textColor = UIColor(red: 0.728, green: 0.728, blue: 0.728, alpha: 1.0)
            borderColor = UIColor(red: 0.0815, green: 0.0815, blue: 0.0815, alpha: 1.0).cgColor
            backColor = UIColor(red: 0.0815, green: 0.0815, blue: 0.0815, alpha: 1.0)
            textColor = UIColor(red: 0.5451, green: 0.5451, blue: 0.5451, alpha: 1.0)
            stop.setTitleColor(textColor, for: UIControlState())
        } else {
            background!.isHidden = false
            timeLabel.textColor = UIColor.white
            timePlus1.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControlState())
            timeMinus1.setTitleColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: UIControlState())
            taskBackground.backgroundColor = UIColor.white
            hintLabel.textColor = UIColor.white
            stop.setTitleColor(textColor, for: UIControlState())
        }
        let timerPlusButtons = [timePlus2,timePlus5,timePlus10,timePlus30,timePlus1h,timeToOClock]
        for aButton in timerPlusButtons {
            aButton?.layer.borderWidth = 1
            aButton?.layer.borderColor = borderColor
            aButton?.backgroundColor = backColor
            aButton?.titleLabel!.adjustsFontSizeToFitWidth = true
            aButton?.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
            aButton?.titleLabel!.baselineAdjustment = UIBaselineAdjustment.alignCenters
            aButton?.setTitleColor(textColor, for: UIControlState())
            aButton?.setBackgroundImage(UIImage(color: tapColor,size: CGSize(width: timePlus1.frame.width, height: timePlus1.frame.width)), for: .highlighted)
        }
        stop.titleLabel!.adjustsFontSizeToFitWidth = true
        stop.titleLabel!.lineBreakMode = NSLineBreakMode.byClipping
        stop.titleLabel!.baselineAdjustment = UIBaselineAdjustment.alignCenters
    }
    
    func turquoiseColor() -> CAGradientLayer { //渐变色层
        let topColor = UIColor(red:0.9725, green:0.3843, blue:0.3333, alpha:1.0)
        let bottomColor = UIColor(red:0.9529, green:0.3412, blue:0.3255, alpha:1.0)
        let gradientColors: Array <AnyObject> = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.colors = gradientColors
        let gradientLocations: Array <NSNumber> = [0.0, 1.0]
        
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    func buttonSound(){
        if pomodoroTimer.enableAlarmSound {
            let SoundPath = Bundle.main.path(forResource: "Click", ofType: "mp3")
            let SoundUrl = URL(fileURLWithPath: SoundPath!)
            do {soundPlayer = try AVAudioPlayer(contentsOf: SoundUrl)} catch _ { }
            soundPlayer!.numberOfLoops = 0
            soundPlayer!.volume = 1
            soundPlayer!.prepareToPlay()
            soundPlayer!.play()
        }
    }
}

public extension UIImage { //生成圆角纯色图片
    public convenience init?(color: UIColor, size: CGSize) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: UIRectCorner.allCorners,cornerRadii: CGSize(width: 2, height: 2))
        color.setFill()
        path.fill()
        UIGraphicsGetCurrentContext()?.addPath(path.cgPath)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}

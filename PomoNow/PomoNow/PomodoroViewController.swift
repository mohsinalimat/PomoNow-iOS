//
//  PomodoroViewController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/7/7.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class PomodoroViewController: UIViewController {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var hintLabel: UILabel!
    @IBOutlet weak var taskBackground: UIView!
    
    var background : CAGradientLayer? = nil
    var timer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(PomodoroViewController.pomodoroStarted), name: NSNotification.Name(rawValue: "PomodoroStarted"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PomodoroViewController.pomodoroStopped), name: NSNotification.Name(rawValue: "PomodoroStopped"), object: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(PomodoroViewController.timing), userInfo: nil, repeats: true)
        
        background = turquoiseColor() //设置背景
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
        self.view.layer.insertSublayer(background!, at: 0)
        
        hintLabel.text = NSLocalizedString("Long press to start", comment:"Long press to start")
        
        //无障碍信息
        timeLabel.accessibilityLabel = pomodoroTimer.timerAccessibilityLabel
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
        setStyleMode()
        timing() // 刷新UI状态
        if pomodoroTimer.pomoMode == 0 {
            pomodoroStopped()
        }
    }
    
    func setStyleMode() { //UI风格变换
        if isDarkMode {
            background!.isHidden = true
            view.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            timeLabel.textColor = UIColor(red: 0.949, green: 0.3373, blue: 0.2824, alpha: 1.0)
            taskBackground.backgroundColor = UIColor(red: 0.0392, green: 0.0392, blue: 0.0392, alpha: 1.0)
            hintLabel.textColor = UIColor(red: 0.728, green: 0.728, blue: 0.728, alpha: 1.0)
        } else {
            background!.isHidden = false
            timeLabel.textColor = UIColor.white
            taskBackground.backgroundColor = UIColor.white
            hintLabel.textColor = UIColor.white
        }
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
    
    func pomodoroStarted() {
        hintLabel.text = NSLocalizedString("Tap anywhere to stop", comment:"Tap anywhere to stop")
    }
    
    func pomodoroStopped() {
        hintLabel.text = NSLocalizedString("Long press to start", comment:"Long press to start")
        if finishFirstPomodoro && isFirst {
            isFirst = false
            dataManagement.setDefaults ("main.isFirst2.0",value: false as AnyObject)
            let alertController = UIAlertController(
                title: NSLocalizedString("Rate PomoNow", comment: "Rate PomoNow"),
                message: NSLocalizedString("Do you like PomoNow? Please tell us.", comment: "Do you like PomoNow? Please tell us."),
                preferredStyle: UIAlertControllerStyle.alert
            )
            
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel"),
                style: UIAlertActionStyle.destructive) { (action) in
            }
            
            let confirmAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.default) { (action) in
                let feedStr  = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1052803982"
                UIApplication.shared.openURL(NSURL(string: feedStr)! as URL)
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
            
        }
    }
    
    func timing() {
        timeLabel.text = pomodoroTimer.timerLabel
        timeLabel.accessibilityLabel = pomodoroTimer.timerAccessibilityLabel
        taskLabel.text = NSLocalizedString("Swipe up anywhere for more detail", comment:"Swipe up anywhere for more detail")
        if pomodoroTimer.pomoMode == 2 || pomodoroTimer.pomoMode == 3 {
            hintLabel.text = NSLocalizedString("Take a break.", comment: "Take a break.")
        } else {
            hintLabel.text = NSLocalizedString("Tap anywhere to stop", comment:"Tap anywhere to stop")
        }
    }
    
    func OrientationChanged() { //屏幕旋转侦测
        if (background != nil) {
            background!.frame.size.height = view.bounds.height + 500
            background!.frame.size.width = view.bounds.width + 500
        }
    }
}

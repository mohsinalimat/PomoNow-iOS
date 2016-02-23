//
//  PomodoroViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/9/15.
//  Copyright (c) 2015年 ScrewBox. All rights reserved.
//

import UIKit

class PomodoroViewController: UIViewController , UINavigationControllerDelegate{

    @IBOutlet weak var TimerView: CProgressView!
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var TimerViewContainer: UIView!
    @IBOutlet weak var readme: UILabel!

    var startbreak = false
    var aniMode = true //进度条动画方向
    var timer: NSTimer?
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    var process: Float { //进度条参数
        get {
            return TimerView.valueProgress / 66.7 * 100
        }
        set {
            TimerView.valueProgress = newValue / 100 * 66.7
            updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapToStop = UITapGestureRecognizer()
        tapToStop.addTarget(self, action: "stopPomo:")
        let pressToStart = UILongPressGestureRecognizer()
        pressToStart.addTarget(self, action: "startPomo:")
        pressToStart.minimumPressDuration = 0.1
        TimerView.addGestureRecognizer(tapToStop)
        TimerView.addGestureRecognizer(pressToStart)
        updateUI()
        
        //软件设置相关
        if getDefaults("main.isFirst") != nil {  //存储默认设置
            isFirst = getDefaults("main.isFirst") as? Bool ?? true
            isDisableLockScreen = getDefaults("main.isDisableLockScreen") as? Bool ?? true
            withTask = getDefaults("main.withTask") as? Bool ?? false
            task = getDefaults("main.task") as? Array<Array<String>> ?? [[String]]()
        } else {
            setDefaults ("main.isFirst",value: true)
            setDefaults ("main.isDisableLockScreen",value: isDisableLockScreen)
            setDefaults ("main.withTask",value: withTask)
            setDefaults ("main.task",value: task)
        }
        
        let app = UIApplication.sharedApplication()
        app.idleTimerDisabled = isDisableLockScreen
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
        if withTask {
            if task.count > 0 {
                for i in 0...task.count - 1 {
                    if task[i][3] == "1" {
                        taskLabel.text = task[i][1]
                    }
                }
            } else {
                withTask = false
                setDefaults ("main.withTask",value: withTask)
                taskLabel.text = NSLocalizedString("Start with a task", comment: "Start with a task")
            }
            
        } else {
            taskLabel.text = NSLocalizedString("Start with a task", comment: "Start with a task")
        }
    }
    
    func updateUI() {
        TimerView.setNeedsDisplay()
        timeLabel.text = pomodoroClass.timerLabel
    }
    
    func stopPomo(sender:UITapGestureRecognizer) {
        pomodoroClass.stop()
        stopTimer()
        process = 0
        taskLabel.textColor = taskColor
    }
    
    func startPomo(sender:UILongPressGestureRecognizer) {
        readme.hidden = true
        if pomodoroClass.pomoMode == 0 {
            if sender.state == UIGestureRecognizerState.Ended {
                pomodoroClass.playSound(5)
                if process < 100 {
                    stopTimer()
                    processToZero()
                } else {
                    pomodoroClass.start()
                    stopTimer()
                    timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "pomoing:", userInfo: nil, repeats: true)
                }
            } else if sender.state == UIGestureRecognizerState.Began {
                if pomodoroClass.pomoMode == 0 {
                    taskLabel.textColor = taskColor
                    needStop = false
                    pomodoroClass.playSound(1)
                    stopTimer()
                    processToFull()
                }
            }
        }
    }
    
    func pomoing(timer:NSTimer) {  //调整进度条
        process = pomodoroClass.process
        if withTask{
            if pomodoroClass.pomoMode == 2 || pomodoroClass.pomoMode == 3 {
                if !startbreak {
                    startbreak = true
                    setDefaults ("main.task",value: task)
                }
            }
            if pomodoroClass.pomoMode == 1 {
                startbreak = false
            }
        }
        if pomodoroClass.pomoMode == 2 || pomodoroClass.pomoMode == 3 {
            taskLabel.textColor = colorGray
        }
        if pomodoroClass.pomoMode == 1 || pomodoroClass.pomoMode == 0 {
            taskLabel.textColor = taskColor
        }
        //alert
        if pomodoroClass.finishOne && isFirst{
            let alertController = UIAlertController(
                title: NSLocalizedString("Rate PomoNow", comment: "Rate PomoNow"),
                message: NSLocalizedString("Do you like PomoNow? Please tell us.", comment: "Do you like PomoNow? Please tell us."),
                preferredStyle: UIAlertControllerStyle.Alert
            )
        
            let cancelAction = UIAlertAction(
                title: NSLocalizedString("Cancel", comment: "Cancel"),
                style: UIAlertActionStyle.Destructive) { (action) in
                isFirst = false
                self.setDefaults ("main.isFirst",value: false)
            }
            
            let confirmAction = UIAlertAction(
                title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default) { (action) in
                    isFirst = false
                    self.setDefaults ("main.isFirst",value: false)
                    let feedStr  = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1052803982"
                    UIApplication.sharedApplication().openURL(NSURL(string: feedStr)!)
            }
            
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
    
    //动画部分Start－－－－－－－－－－
    func processToZero() { //更新进度条状态
        aniMode = true
        needStop = true
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "processAnimation:", userInfo: nil, repeats: true)
    }
    
    func processToFull() {
        aniMode = false
        timer = NSTimer.scheduledTimerWithTimeInterval(0.01, target: self, selector: "processAnimation:", userInfo: nil, repeats: true)
    }
    
    func processAnimation(timer: NSTimer) {
        if aniMode {
            if process >= 0 {
                process -= 1
            }else {
                stopTimer()
            }
        } else {
            if process <= 100 {
                process += 1
            }else {
                stopTimer()
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    //动画部分End－－－－－－－－－－
    override func shouldAutorotate() -> Bool {
        if (UIDevice.currentDevice().userInterfaceIdiom == .Phone) {
            return false
        } else {
            return true
        }
    }
    
    
    func getDefaults (key: String) -> AnyObject? {
        if key != "" {
            return defaults.objectForKey(key)
        } else {
            return nil
        }
    }
    
    func setDefaults (key: String,value: AnyObject) {
        if key != "" {
            defaults.setObject(value,forKey: key)
        }
    }
    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.Push {
            return AnimationToList()
        } else {
            return nil
        }
    }
}

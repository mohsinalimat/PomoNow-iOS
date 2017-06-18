//
//  SettingsViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/3.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBAction func cancel(sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        self.performSegueWithIdentifier("backToList", sender: self)
    }
    
    @IBAction func ok(sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        self.performSegueWithIdentifier("backToList", sender: self)
    }
    
    @IBAction func toGithub(sender: AnyObject) {
        let feedStr  = "https://github.com/megabitsenmzq/PomoNow-iOS"
        UIApplication.sharedApplication().openURL(NSURL(string: feedStr)!)
    }
    
    @IBOutlet weak var TimerView: CProgressView!
    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        process = pomodoroClass.process
        updateUI()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(SettingsViewController.getNowtime(_:)), userInfo: nil, repeats: true)
    }
    
    var timer: NSTimer?
    
    var process: Float { //进度条
        get {
            return TimerView.valueProgress / 67 * 100
        }
        set {
            TimerView.valueProgress = newValue / 100 * 67
            updateUI()
        }
    }
    
    private func updateUI() {
        TimerView.setNeedsDisplay()
        timeLabel.text = pomodoroClass.timerLabel
    }
    
    func getNowtime(timer:NSTimer) {  //同步时间
        process = pomodoroClass.process
        updateUI()
    }

}

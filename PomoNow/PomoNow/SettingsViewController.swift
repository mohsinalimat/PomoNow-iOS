//
//  SettingsViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/3.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    
    @IBAction func cancel(_ sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func ok(_ sender: AnyObject) {
        timer?.invalidate()
        timer = nil
        self.dismiss(animated: true, completion: {})
    }
    
    @IBAction func toGithub(_ sender: AnyObject) {
        let feedStr  = "https://github.com/megabitsenmzq/PomoNow-iOS"
        UIApplication.shared.openURL(URL(string: feedStr)!)
    }
    
    @IBOutlet weak var TimerView: CProgressView!
    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        process = pomodoroClass.process
        updateUI()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(SettingsViewController.getNowtime(_:)), userInfo: nil, repeats: true)
    }
    
    var timer: Timer?
    
    var process: Float { //进度条
        get {
            return TimerView.valueProgress / 67 * 100
        }
        set {
            TimerView.valueProgress = newValue / 100 * 67
            updateUI()
        }
    }
    
    fileprivate func updateUI() {
        TimerView.setNeedsDisplay()
        timeLabel.text = pomodoroClass.timerLabel
    }
    
    @objc func getNowtime(_ timer:Timer) {  //同步时间
        process = pomodoroClass.process
        updateUI()
    }

}

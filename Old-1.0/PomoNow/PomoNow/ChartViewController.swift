//
//  ChartViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/11/24.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {

    @IBOutlet var StartLabel: UILabel!
    @IBOutlet var StatisticsContainer: UIView!
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
    @IBOutlet weak var TimerView: CProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    var timer: NSTimer?
    override func viewDidLoad() {
        super.viewDidLoad()
        process = pomodoroClass.process
        updateUI()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: #selector(ChartViewController.getNowtime(_:)), userInfo: nil, repeats: true)
    }
    
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
        var haveData = 0
        for i in 0...6 {
            if cManager.chart[i][0] > 0{
                haveData += 1
            }
        }
        if haveData == 0 {
            StartLabel.hidden = false
            StatisticsContainer.hidden = true
        } else {
            StartLabel.hidden = true
            StatisticsContainer.hidden = false
        }
    }
    
    func getNowtime(timer:NSTimer) {  //同步时间
        process = pomodoroClass.process
        updateUI()
    }

}

//
//  PomoListViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/9/28.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

class PomoListViewController: UIViewController , UINavigationControllerDelegate{
    
    @IBOutlet weak var TimerView: CProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var round: UIImageView!
    @IBOutlet weak var addOneLabel: UILabel!
    @IBOutlet var swipeDown: UISwipeGestureRecognizer!
    @IBOutlet var swipeDown2: UISwipeGestureRecognizer!
    @IBOutlet var swipeDown3: UISwipeGestureRecognizer!
    @IBOutlet var swipeRight: UISwipeGestureRecognizer!
    @IBOutlet var swipeRight2: UISwipeGestureRecognizer!
    @IBAction func pop(sender: UITapGestureRecognizer) {
        timer?.invalidate()
        timer = nil
        taskTable.setEditing(false, animated:true)
        self.navigationController?.popViewControllerAnimated(true)
    }
    @IBAction func swipePop(sender: UISwipeGestureRecognizer) {
        timer?.invalidate()
        timer = nil
        if sender.direction == UISwipeGestureRecognizerDirection.Down || sender.direction == UISwipeGestureRecognizerDirection.Right {
            taskTable.setEditing(false, animated:true)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    @IBOutlet weak var taskTable: TaskTableView!
    
    @IBAction func toSettings(sender: AnyObject) {
        taskTable.setEditing(false, animated:true)
        self.performSegueWithIdentifier("toSettings", sender: self)
    }
    
    @IBOutlet weak var uiView: UIView!
    @IBAction func addTask(sender: UIButton) { //添加新任务
        taskTable.setEditing(false, animated:true)
        Dialog().showAddTask(NSLocalizedString("Add task", comment: "addtask"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel")) {
            (timer) -> Void in
            if taskString != "" {
                let nowDate = NSDate() //当前添加的任务的时间信息
                let formatter = NSDateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.stringFromDate(nowDate)
                
                self.addOneLabel.hidden = true
                self.taskTable.hidden = false
                if task.count == 0 {
                    withTask = true
                    task.append([String(selectTag),taskString,"0","1",dateString])
                    pomodoroClass.stop()
                } else {
                    task.append([String(selectTag),taskString,"0","0",dateString])
                }
                self.setDefaults ("main.withTask",value: withTask)
                self.setDefaults ("main.task",value: task)
                self.taskTable.reloadData()
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        process = pomodoroClass.process
        updateUI()
        timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "getNowtime:", userInfo: nil, repeats: true)
        if task.count == 0{
            addOneLabel.hidden = false
            taskTable.hidden = true
        }
        //返回上一级界面允许向右和向下两种手势
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        swipeDown2.direction = UISwipeGestureRecognizerDirection.Down
        swipeDown3.direction = UISwipeGestureRecognizerDirection.Down
        swipeRight.direction = UISwipeGestureRecognizerDirection.Right
        swipeRight2.direction = UISwipeGestureRecognizerDirection.Right
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    func getNowtime(timer:NSTimer) {  //同步时间
        process = pomodoroClass.process
        if task.count == 0 {
            addOneLabel.hidden = false
            taskTable.hidden = true
        }
        if taskChanged {
            taskChanged = false
            taskTable.reloadData()
        }
    }
    
    @IBAction func returnFromSegueActions(sender: UIStoryboardSegue){
        
    }
    
    @IBAction func buyOne(sender: AnyObject) {
        let alertController = UIAlertController(
            title: "BuyOne",
            message: "Please buy PomoNow on Appstore",
            preferredStyle: UIAlertControllerStyle.Alert
        )
        
        let confirmAction = UIAlertAction(
            title: NSLocalizedString("OK", comment: "OK"), style: UIAlertActionStyle.Default) { (action) in
        }
        
        alertController.addAction(confirmAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }

    
    func navigationController(navigationController: UINavigationController, animationControllerForOperation operation: UINavigationControllerOperation, fromViewController fromVC: UIViewController, toViewController toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.Pop {
            return AnimationFromList()
        } else {
            return nil
        }
    }
    
    //NSUserDefaults
    private let defaults = NSUserDefaults.standardUserDefaults()
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
}
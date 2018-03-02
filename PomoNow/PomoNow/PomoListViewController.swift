//
//  PomoListViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/9/28.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
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
    
    @IBAction func pop(_ sender: UITapGestureRecognizer) {
        timer?.invalidate()
        timer = nil
        taskTable.setEditing(false, animated:true)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swipePop(_ sender: UISwipeGestureRecognizer) {
        timer?.invalidate()
        timer = nil
        if sender.direction == UISwipeGestureRecognizerDirection.down || sender.direction == UISwipeGestureRecognizerDirection.right {
            taskTable.setEditing(false, animated:true)
            self.navigationController?.popViewController(animated: true)
        }
    }
    @IBOutlet weak var taskTable: TaskTableView!
    
    @IBAction func toSettings(_ sender: AnyObject) {
        taskTable.setEditing(false, animated:true)
        self.performSegue(withIdentifier: "toSettings", sender: self)
    }
    
    @IBOutlet weak var ListContainer: UIView!
    
    @IBAction func addTask(_ sender: UIButton) { //添加新任务
        taskTable.setEditing(false, animated:true)
        Dialog().showAddTask(NSLocalizedString("Add task", comment: "addtask"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel")) {
            (timer) -> Void in
            if taskString != "" {
                let nowDate = Date() //当前添加的任务的时间信息
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let dateString = formatter.string(from: nowDate)
                
                self.addOneLabel.isHidden = true
                self.taskTable.isHidden = false
                if task.count == 0 {
                    withTask = true
                    task.append([String(selectTag),taskString,"0","1",dateString])
                    pomodoroClass.stop()
                } else {
                    task.append([String(selectTag),taskString,"0","0",dateString])
                }
                self.setDefaults ("main.withTask",value: withTask as AnyObject)
                self.setDefaults ("main.task",value: task as AnyObject)
                self.taskTable.reloadData()
            }
        }
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        process = pomodoroClass.process
        updateUI()
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(PomoListViewController.getNowtime(_:)), userInfo: nil, repeats: true)
        if task.count == 0{
            addOneLabel.isHidden = false
            taskTable.isHidden = true
        }
        //返回上一级界面允许向右和向下两种手势
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        swipeDown2.direction = UISwipeGestureRecognizerDirection.down
        swipeDown3.direction = UISwipeGestureRecognizerDirection.down
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationController?.delegate = self
    }
    
    @objc func getNowtime(_ timer:Timer) {  //同步时间
        process = pomodoroClass.process
        if task.count == 0 {
            addOneLabel.isHidden = false
            taskTable.isHidden = true
        }
        if taskChanged {
            taskChanged = false
            taskTable.reloadData()
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.pop {
            return AnimationFromList()
        } else {
            return nil
        }
    }
    
    //NSUserDefaults
    fileprivate let defaults = UserDefaults.standard
    func getDefaults (_ key: String) -> AnyObject? {
        if key != "" {
            return defaults.object(forKey: key) as AnyObject
        } else {
            return nil
        }
    }
    
    func setDefaults (_ key: String,value: AnyObject) {
        if key != "" {
            defaults.set(value,forKey: key)
        }
    }
}

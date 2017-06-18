//
//  TaskTableView.swift
//  PomoNow
//
//  Created by Megabits on 15/10/17.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit

class TaskTableView: UITableView, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate{
    
    required init(coder aDecoder:NSCoder){
        super.init(coder: aDecoder)!
        self.dataSource = self
        self.delegate = self
        let longPress =  UILongPressGestureRecognizer(target:self, action:#selector(TaskTableView.tableviewCellLongPressed(_:)))
        longPress.minimumPressDuration = 0.3
        longPress.delegate = self
        self.addGestureRecognizer(longPress)
        
        if getDefaults("main.task") != nil {  //存储默认设置
            task = getDefaults("main.task") as? Array<Array<String>> ?? [[String]]()
        } else {
            setDefaults ("main.task",value: task)
        }
        
    }
    
    func tableviewCellLongPressed(gestureRecognizer:UILongPressGestureRecognizer)
    { //长按移动项目
        let longPress = gestureRecognizer as UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.locationInView(self)
        let indexPath = self.indexPathForRowAtPoint(locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : NSIndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.Began:
            if indexPath != nil {
                if let cell = self.cellForRowAtIndexPath(indexPath!) as UITableViewCell! {
                    Path.initialIndexPath = indexPath
                    My.cellSnapshot  = snapshopOfCell(cell)
                    var center = cell.center
                    My.cellSnapshot!.center = center
                    
                    self.addSubview(My.cellSnapshot!)
                    cell.hidden = true
                    UIView.animateWithDuration(0.25, animations: { () -> Void in
                        center.y = locationInView.y
                        My.cellSnapshot!.center = center
                        My.cellSnapshot!.transform = CGAffineTransformMakeScale(1.05, 1.05)
                        }, completion: { (finished) -> Void in
                            if finished {
                                
                            }
                    })
                }
                
                
            }
        case UIGestureRecognizerState.Changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if (indexPath != nil) && (indexPath != Path.initialIndexPath) {
                    swap(&task[indexPath!.row], &task[Path.initialIndexPath!.row])
                    setDefaults ("main.task",value:task)
                    setDefaults ("main.withTask",value: withTask)
                    self.moveRowAtIndexPath(Path.initialIndexPath!, toIndexPath: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
            
        default:
            if My.cellSnapshot != nil {
                if let cell = self.cellForRowAtIndexPath(Path.initialIndexPath!) as UITableViewCell! {
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        My.cellSnapshot!.center = cell.center
                        My.cellSnapshot!.transform = CGAffineTransformIdentity
                        }, completion: { (finished) -> Void in
                            if finished {
                                My.cellSnapshot!.alpha = 0.0
                                cell.hidden = false
                                Path.initialIndexPath = nil
                                My.cellSnapshot!.removeFromSuperview()
                                My.cellSnapshot = nil
                            }
                    })
                } else {
                    Path.initialIndexPath = nil
                    My.cellSnapshot!.removeFromSuperview()
                    My.cellSnapshot = nil
                }
            }
            
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext() as UIImage
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSizeMake(-5.0, 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return task.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{ //录入数据
        let cell = tableView.dequeueReusableCellWithIdentifier("taskCell", forIndexPath: indexPath) as! TaskTableViewCell
        cell.taskLabel.text = task[indexPath.row][1]
        cell.tagColor = Int(task[indexPath.row][0])!
        cell.times.text = task[indexPath.row][2]
        cell.alpha = 1
        let select = task[indexPath.row][3]
        if select == "0" {
            cell.accessoryType=UITableViewCellAccessoryType.None
        } else {
            cell.accessoryType=UITableViewCellAccessoryType.Checkmark
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){ //实现单选选择
        withTask = true
        if pomodoroClass.pomoMode == 1 {
            pomodoroClass.stop()
        }
        for i in 0...task.count - 1 {
            task[i][3] = "0"
        }
        task[indexPath.row][3] = "1"
        setDefaults ("main.withTask",value: withTask)
        setDefaults ("main.task",value: task)
        reloadData()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) { //可删除
        if editingStyle == UITableViewCellEditingStyle.Delete {
            if task[indexPath.row][3] == "1" {
                withTask = false
            }
            task.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            setDefaults ("main.task",value: task)
            setDefaults ("main.withTask",value: withTask)
        }
    }
    
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
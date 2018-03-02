//
//  TaskTableView.swift
//  PomoNow
//
//  Created by Megabits on 15/10/17.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
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
            setDefaults ("main.task",value: task as AnyObject)
        }
        
    }
    
    @objc func tableviewCellLongPressed(_ gestureRecognizer:UILongPressGestureRecognizer)
    { //长按移动项目
        let longPress = gestureRecognizer as UILongPressGestureRecognizer
        let state = longPress.state
        let locationInView = longPress.location(in: self)
        let indexPath = self.indexPathForRow(at: locationInView)
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizerState.began:
            if indexPath != nil {
                if let cell = self.cellForRow(at: indexPath!) as UITableViewCell! {
                    Path.initialIndexPath = indexPath
                    My.cellSnapshot  = snapshopOfCell(cell)
                    var center = cell.center
                    My.cellSnapshot!.center = center
                    
                    self.addSubview(My.cellSnapshot!)
                    cell.isHidden = true
                    UIView.animate(withDuration: 0.25, animations: { () -> Void in
                        center.y = locationInView.y
                        My.cellSnapshot!.center = center
                        My.cellSnapshot!.transform = CGAffineTransform(scaleX: 1.05, y: 1.05)
                        }, completion: { (finished) -> Void in
                    })
                }
                
                
            }
        case UIGestureRecognizerState.changed:
            if My.cellSnapshot != nil {
                var center = My.cellSnapshot!.center
                center.y = locationInView.y
                My.cellSnapshot!.center = center
                if (indexPath != nil) && (indexPath != Path.initialIndexPath) {
                    let a = task[indexPath!.row]
                    task[indexPath!.row] = task[Path.initialIndexPath!.row]
                    task[Path.initialIndexPath!.row] = a
                    setDefaults ("main.task",value:task as AnyObject)
                    setDefaults ("main.withTask",value: withTask as AnyObject)
                    self.moveRow(at: Path.initialIndexPath!, to: indexPath!)
                    Path.initialIndexPath = indexPath
                }
            }
            
        default:
            if My.cellSnapshot != nil {
                if let cell = self.cellForRow(at: Path.initialIndexPath!) as UITableViewCell! {
                    UIView.animate(withDuration: 0.2, animations: { () -> Void in
                        My.cellSnapshot!.center = cell.center
                        My.cellSnapshot!.transform = CGAffineTransform.identity
                        }, completion: { (finished) -> Void in
                            if finished {
                                My.cellSnapshot!.alpha = 0.0
                                cell.isHidden = false
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
    
    func snapshopOfCell(_ inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return task.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{ //录入数据
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskTableViewCell
        cell.taskLabel.text = task[indexPath.row][1]
        cell.tagColor = Int(task[indexPath.row][0])!
        cell.times.text = task[indexPath.row][2]
        cell.alpha = 1
        let select = task[indexPath.row][3]
        if select == "0" {
            cell.accessoryType=UITableViewCellAccessoryType.none
        } else {
            cell.accessoryType=UITableViewCellAccessoryType.checkmark
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){ //实现单选选择
        withTask = true
        if pomodoroClass.pomoMode == 1 {
            pomodoroClass.stop()
        }
        for i in 0...task.count - 1 {
            task[i][3] = "0"
        }
        task[indexPath.row][3] = "1"
        setDefaults ("main.withTask",value: withTask as AnyObject)
        setDefaults ("main.task",value: task as AnyObject)
        reloadData()
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) { //可删除
        if editingStyle == UITableViewCellEditingStyle.delete {
            if task[indexPath.row][3] == "1" {
                withTask = false
            }
            task.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            setDefaults ("main.task",value: task as AnyObject)
            setDefaults ("main.withTask",value: withTask as AnyObject)
        }
    }
    
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

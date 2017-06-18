//
//  SettingsTableViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/13.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController ,MFMailComposeViewControllerDelegate{
    
    @IBOutlet weak var workLabel: UILabel!
    @IBOutlet weak var breakLabel: UILabel!
    @IBOutlet weak var longBreakLabel: UILabel!
    @IBOutlet weak var longBreakDelayLabel: UILabel!
    @IBOutlet weak var tsSwitch: UISwitch!
    @IBOutlet weak var asSwitch: UISwitch!
    @IBOutlet weak var dlsSwitch: UISwitch!
    @IBOutlet weak var ctSwitch: UISwitch!
    
    @IBAction func timerSoundSwitch(sender: UISwitch) {
        pomodoroClass.enableTimerSound = sender.on
        pomodoroClass.stopSound()
    }

    @IBAction func alarmSoundSwitch(sender: UISwitch) {
        pomodoroClass.enableAlarmSound = sender.on
    }
    
    @IBAction func disableLockScreenSwitch(sender: UISwitch) {
        isDisableLockScreen = sender.on
        setDefaults ("main.isDisableLockScreen",value: isDisableLockScreen)
        let app = UIApplication.sharedApplication()
        app.idleTimerDisabled = isDisableLockScreen
    }
    
    @IBAction func continuousTimingSwitch(sender: UISwitch) {
        pomodoroClass.longBreakEnable = sender.on
    }
    
     override func viewDidLoad() {
        super.viewDidLoad() //设置初始值的显示
        self.workLabel.text = self.updateDisplay(0)
        self.breakLabel.text = self.updateDisplay(1)
        self.longBreakLabel.text = self.updateDisplay(2)
        tsSwitch.on = pomodoroClass.enableTimerSound
        asSwitch.on = pomodoroClass.enableAlarmSound
        dlsSwitch.on = isDisableLockScreen
        ctSwitch.on = pomodoroClass.longBreakEnable
        longBreakDelayLabel.text = "\(pomodoroClass.longBreakCount) " + NSLocalizedString("Pomodoros", comment: "pd")
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 12
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {  //使列表项可以点击
        if indexPath.section == 0 && indexPath.row >= 5 && indexPath.row <= 10 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(tableView: UITableView,
        didSelectRowAtIndexPath indexPath: NSIndexPath) { //点击列表项的处理
            if indexPath.section == 0 {
                switch indexPath.row{
                case 5:
                    Dialog().showDatePicker(NSLocalizedString("Set Pomodoro Length", comment: "spl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.pomoTime), datePickerMode: .CountDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer % 60))
                        if setTimer != pomodoroClass.pomoTime {
                            pomodoroClass.pomoTime = setTimer
                            pomodoroClass.stop()
                        }
                        self.workLabel.text = self.updateDisplay(0)
                    }
                case 6:
                    Dialog().showDatePicker(NSLocalizedString("Set Break Length", comment: "sbl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.breakTime), datePickerMode: .CountDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer % 60))
                        if setTimer != pomodoroClass.breakTime {
                            pomodoroClass.breakTime = setTimer
                            pomodoroClass.stop()
                        }
                        self.breakLabel.text = self.updateDisplay(1)
                    }
                case 7:
                    Dialog().showDatePicker(NSLocalizedString("Set Long Break Length", comment: "slbl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.longBreakTime), datePickerMode: .CountDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer % 60))
                        if setTimer != pomodoroClass.longBreakTime {
                            pomodoroClass.longBreakTime = setTimer
                            pomodoroClass.stop()
                        }
                        self.longBreakLabel.text = self.updateDisplay(2)
                    }
                case 8:
                    Dialog().showPicker(NSLocalizedString("Set Long break delay", comment: "slbd"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"), defaults: pomodoroClass.longBreakCount - 1) {
                        (rowSelect) -> Void in
                        if Int(rowSelect) + 1 != pomodoroClass.longBreakCount {
                            pomodoroClass.longBreakCount = Int(rowSelect) + 1
                            pomodoroClass.stop()
                        }
                        self.longBreakDelayLabel.text = "\(pomodoroClass.longBreakCount) " + NSLocalizedString("Pomodoros", comment: "pd")
                    }
                case 9:
                    let feedStr  = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1052803982"
                    UIApplication.sharedApplication().openURL(NSURL(string: feedStr)!)
                case 10:
                    if MFMailComposeViewController.canSendMail(){ 
                        let controller = MFMailComposeViewController()
                        //设置代理
                        controller.mailComposeDelegate = self
                        //设置主题
                        controller.setSubject("PomoNow Review")
                        //设置收件人
                        controller.setToRecipients(["megabits_mzq@icloud.com"])
                        
                        //设置邮件正文内容（支持html）
                        controller.setMessageBody("", isHTML: false)
                        
                        //打开界面
                        self.presentViewController(controller, animated: true, completion: nil)
                    }else{
                        print("本设备不能发送邮件")
                    }
                default:break
                }
                
            }
    }
    
    func mailComposeController(controller: MFMailComposeViewController,
        didFinishWithResult result: MFMailComposeResult, error: NSError?) {
            controller.dismissViewControllerAnimated(true, completion: nil)
            
    }
    
    func updateDisplay(select:Int) -> String { //输出时间的文本表示
        var display = ""
        switch pomodoroClass.getStringOfTime(select) {
        case 1:display = pomodoroClass.timerLabelSec + " Sec"
        case 2:display = pomodoroClass.timerLabelMin + " " + NSLocalizedString("min", comment: "min")
        case 3:display = pomodoroClass.timerLabelHour + " " + NSLocalizedString("h", comment: "hour") + " " + pomodoroClass.timerLabelMin + " " + NSLocalizedString("min", comment: "min")
        default:break
        }
        return display
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

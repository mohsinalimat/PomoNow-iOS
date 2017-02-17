//
//  SettingsViewController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/13.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: UITableViewController ,MFMailComposeViewControllerDelegate{

    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var label5: UILabel!
    @IBOutlet weak var label6: UILabel!
    @IBOutlet weak var label7: UILabel!
    @IBOutlet weak var label8: UILabel!
    @IBOutlet weak var label9: UILabel!
    @IBOutlet weak var label10: UILabel!
    @IBOutlet weak var label11: UILabel!
    @IBOutlet weak var done: UIBarButtonItem!
    @IBOutlet weak var tickingSoundSwitch: UISwitch!
    @IBOutlet weak var promptSoundSwitch: UISwitch!
    @IBOutlet weak var darkModeSwitch: UISwitch!
    @IBOutlet weak var disableLockScreenSwitch: UISwitch!
    @IBOutlet weak var longBreakEnableSwitch: UISwitch!
    
    @IBOutlet weak var pomoTime: UILabel!
    @IBOutlet weak var breakTime: UILabel!
    @IBOutlet weak var longBreakTime: UILabel!
    @IBOutlet weak var longBreakDelay: UILabel!
    
    var labels = [UILabel]()
    
    @IBAction func done(_ sender: AnyObject) {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setTickingSound(_ sender: UISwitch) {
        pomodoroTimer.enableTimerSound = sender.isOn
        pomodoroTimer.stopSound()
    }
    
    @IBAction func setPromptSound(_ sender: UISwitch) {
        pomodoroTimer.enableAlarmSound = sender.isOn
    }
    
    @IBAction func setDarkMode(_ sender: UISwitch) {
        isDarkMode = sender.isOn
        dataManagement.setDefaults("main.isDarkMode", value: isDarkMode as AnyObject)
        NotificationCenter.default.post(name: Notification.Name(rawValue: "changeStyle"), object: self, userInfo: nil)
        UIView.animate(withDuration: 0.4, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.setStyleMode()
        }) { (finish: Bool) -> Void in
        }
    }
    
    @IBAction func setDisableLockScreen(_ sender: UISwitch) {
        isDisableLockScreen = sender.isOn
        dataManagement.setDefaults ("main.isDisableLockScreen",value: isDisableLockScreen as AnyObject)
        let app = UIApplication.shared
        app.isIdleTimerDisabled = isDisableLockScreen
    }
    
    @IBAction func setLongBreakEnable(_ sender: UISwitch) {
        pomodoroTimer.longBreakEnable = sender.isOn
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labels = [label1,label2,label3,label4,label5,label6,label7,label8,label9,label10,label11]
        setStyleMode()
        //获取当前状态
        tickingSoundSwitch.isOn = pomodoroTimer.enableTimerSound
        promptSoundSwitch.isOn = pomodoroTimer.enableAlarmSound
        longBreakEnableSwitch.isOn = pomodoroTimer.longBreakEnable
        darkModeSwitch.isOn = isDarkMode
        disableLockScreenSwitch.isOn = isDisableLockScreen
        updateTimeLabel()
        if !MFMailComposeViewController.canSendMail(){
            label11.text = NSLocalizedString("This device can't send E-mail.", comment: "This device can't send E-mail.")
        }
    }
    
    override func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) { //点击列表项的处理
        if (indexPath as NSIndexPath).section == 2{
            if (indexPath as NSIndexPath).row == 0{
                Dialog().showDatePicker(NSLocalizedString("Set Pomodoro Length", comment: "Set Pomodoro Length"), doneButtonTitle: NSLocalizedString("Done", comment: "Done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),defaultTime: Double(pomodoroTimer.pomoTime), datePickerMode: .countDownTimer) {
                    (timer) -> Void in
                    let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
                    if setTimer != pomodoroTimer.pomoTime {
                        pomodoroTimer.pomoTime = setTimer
                        pomodoroTimer.stop()
                    }
                    self.updateTimeLabel()
                }
            } else if (indexPath as NSIndexPath).row == 1{
                Dialog().showDatePicker(NSLocalizedString("Set Break Length", comment: "Set Break Length"), doneButtonTitle: NSLocalizedString("Done", comment: "Done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),defaultTime: Double(pomodoroTimer.breakTime), datePickerMode: .countDownTimer) {
                    (timer) -> Void in
                    let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
                    if setTimer != pomodoroTimer.breakTime {
                        pomodoroTimer.breakTime = setTimer
                        pomodoroTimer.stop()
                    }
                    self.updateTimeLabel()
                }
            } else if (indexPath as NSIndexPath).row == 3{
                Dialog().showDatePicker(NSLocalizedString("Set Long Break Length", comment: "Set Long Break Length"), doneButtonTitle: NSLocalizedString("Done", comment: "Done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"),defaultTime: Double(pomodoroTimer.longBreakTime), datePickerMode: .countDownTimer) {
                    (timer) -> Void in
                    let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
                    if setTimer != pomodoroTimer.longBreakTime {
                        pomodoroTimer.longBreakTime = setTimer
                        pomodoroTimer.stop()
                    }
                    self.updateTimeLabel()
                }
            } else if (indexPath as NSIndexPath).row == 4{
                Dialog().showPicker(NSLocalizedString("Set Long break delay", comment: "Set Long break delay"), doneButtonTitle: NSLocalizedString("Done", comment: "Done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "Cancel"), defaults: pomodoroTimer.longBreakCount - 1) {
                    (rowSelect) -> Void in
                    if Int(rowSelect) + 1 != pomodoroTimer.longBreakCount {
                        pomodoroTimer.longBreakCount = Int(rowSelect) + 1
                        pomodoroTimer.stop()
                    }
                    self.updateTimeLabel()
                }
            }
        } else if (indexPath as NSIndexPath).section == 3{
            if (indexPath as NSIndexPath).row == 0{
                let feedStr  = "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=1052803982"
                UIApplication.shared.openURL(URL(string: feedStr)!)
            } else if (indexPath as NSIndexPath).row == 1{
                if MFMailComposeViewController.canSendMail(){
                    let controller = MFMailComposeViewController()
                    controller.mailComposeDelegate = self
                    controller.setSubject("PomoNow Review")
                    controller.setToRecipients(["megabitsenmzq@gmail.com"])
                    controller.setMessageBody("", isHTML: false)
                    present(controller, animated: true, completion: nil)
                }else{
                    //To-do
                    print("本设备不能发送邮件,请发送邮件到 megabitsenmzq@gmail.com 反馈")
                }
            }
        }
    }
    
    override func scrollViewDidScroll(_ scrollView: UIScrollView) { //滑动屏幕时切换之前在屏幕之外的cell的外观
        setStyleMode()
    }
    
    func updateTimeLabel() { //获取番茄钟时间参数的文本表示
        let pomoTimeSet = pomodoroTimer.getStringOfTime(0)
        let breakTimeSet = pomodoroTimer.getStringOfTime(1)
        let longBreakSet = pomodoroTimer.getStringOfTime(2)
        var pomoTimeText = ""
        var breakTimeText = ""
        var longBreakTimeText = ""
        switch pomoTimeSet.count {
        case 2:pomoTimeText = "\(pomoTimeSet.min) " + NSLocalizedString("min",comment:"min")
        case 3:pomoTimeText = "\(pomoTimeSet.hour) " + NSLocalizedString("h",comment:"h") + " \(pomoTimeSet.min) " + NSLocalizedString("min",comment:"min")
        default:break
        }
        switch breakTimeSet.count {
        case 2:breakTimeText = "\(breakTimeSet.min) " + NSLocalizedString("min",comment:"min")
        case 3:breakTimeText = "\(breakTimeSet.hour) " + NSLocalizedString("h",comment:"h") + " \(breakTimeSet.min) " + NSLocalizedString("min",comment:"min")
        default:break
        }
        switch longBreakSet.count {
        case 2:longBreakTimeText = "\(longBreakSet.min) " + NSLocalizedString("min",comment:"min")
        case 3:longBreakTimeText = "\(longBreakSet.hour) " + NSLocalizedString("h",comment:"h") + " \(longBreakSet.min) " + NSLocalizedString("min",comment:"min")
        default:break
        }
        
        pomoTime.text = pomoTimeText
        breakTime.text = breakTimeText
        longBreakTime.text = longBreakTimeText
        longBreakDelay.text = "\(pomodoroTimer.longBreakCount) " + NSLocalizedString("pomodoro",comment:"pomodoro")
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,didFinishWith result: MFMailComposeResult, error: Error?) { //邮件发送取消后回到App里
        controller.dismiss(animated: true, completion: nil)
        
    }

    func setStyleMode() { //UI风格变换
        if isDarkMode {
            view.backgroundColor = UIColor(red:0.1922, green:0.1922, blue:0.1922, alpha:1.0)
            tableView.backgroundView?.backgroundColor = UIColor(red:0.1922, green:0.1922, blue:0.1922, alpha:1.0)
            tableView.separatorColor = UIColor(red:0.3137, green:0.3137, blue:0.3137, alpha:1.0)
            navigationController?.navigationBar.barTintColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red:0.6549, green:0.6549, blue:0.6549, alpha:1.0)]
            navigationController?.navigationBar.tintColor = UIColor(red:0.9412, green:0.3412, blue:0.302, alpha:1.0)
            for sectionIndex in 0...tableView.numberOfSections - 1 {
                let header = tableView.headerView(forSection: sectionIndex)
                let footer = tableView.footerView(forSection: sectionIndex)
                header?.contentView.backgroundColor = UIColor(red:0.1922, green:0.1922, blue:0.1922, alpha:1.0)
                footer?.contentView.backgroundColor = UIColor(red:0.1922, green:0.1922, blue:0.1922, alpha:1.0)
                for rowIndex in 0...tableView.numberOfRows(inSection: sectionIndex) - 1 {
                    let cellPath = IndexPath(row: rowIndex, section: sectionIndex)
                    let cell = tableView.cellForRow(at: cellPath)
                    cell?.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
                }
            }
            for aLabel in labels {
                aLabel.textColor = UIColor(red:0.6549, green:0.6549, blue:0.6549, alpha:1.0)
            }
            
        } else {
            view.backgroundColor = UIColor.white
            tableView.backgroundColor = UIColor(red:0.9529, green:0.9529, blue:0.9529, alpha:1.0)
            tableView.separatorColor = UIColor(red:0.7372, green:0.7371, blue:0.7372, alpha:1.0)
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.black]
            navigationController?.navigationBar.tintColor = UIColor(red:0.9412, green:0.3412, blue:0.302, alpha:1.0)
            for sectionIndex in 0...tableView.numberOfSections - 1 {
                let header = tableView.headerView(forSection: sectionIndex)
                let footer = tableView.footerView(forSection: sectionIndex)
                header?.contentView.backgroundColor = UIColor(red:0.9529, green:0.9529, blue:0.9529, alpha:1.0)
                footer?.contentView.backgroundColor = UIColor(red:0.9529, green:0.9529, blue:0.9529, alpha:1.0)
                for rowIndex in 0...tableView.numberOfRows(inSection: sectionIndex) - 1 {
                    let cellPath = IndexPath(row: rowIndex, section: sectionIndex)
                    let cell = tableView.cellForRow(at: cellPath)
                    cell?.backgroundColor = UIColor.white
                    //do stuff with 'cell'
                }
            }
            for aLabel in labels {
                aLabel.textColor = UIColor.black
            }
        }
    }

}

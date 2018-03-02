//
//  SettingsTableViewController.swift
//  PomoNow
//
//  Created by Megabits on 15/10/13.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
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
    
    @IBAction func timerSoundSwitch(_ sender: UISwitch) {
        pomodoroClass.enableTimerSound = sender.isOn
        pomodoroClass.stopSound()
    }

    @IBAction func alarmSoundSwitch(_ sender: UISwitch) {
        pomodoroClass.enableAlarmSound = sender.isOn
    }
    
    @IBAction func disableLockScreenSwitch(_ sender: UISwitch) {
        isDisableLockScreen = sender.isOn
        setDefaults ("main.isDisableLockScreen",value: isDisableLockScreen as AnyObject)
        let app = UIApplication.shared
        app.isIdleTimerDisabled = isDisableLockScreen
    }
    
    @IBAction func continuousTimingSwitch(_ sender: UISwitch) {
        pomodoroClass.longBreakEnable = sender.isOn
    }
    
     override func viewDidLoad() {
        super.viewDidLoad() //设置初始值的显示
        self.workLabel.text = self.updateDisplay(0)
        self.breakLabel.text = self.updateDisplay(1)
        self.longBreakLabel.text = self.updateDisplay(2)
        tsSwitch.isOn = pomodoroClass.enableTimerSound
        asSwitch.isOn = pomodoroClass.enableAlarmSound
        dlsSwitch.isOn = isDisableLockScreen
        ctSwitch.isOn = pomodoroClass.longBreakEnable
        longBreakDelayLabel.text = "\(pomodoroClass.longBreakCount) " + NSLocalizedString("Focus Cycle", comment: "pd")
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {  //使列表项可以点击
        if indexPath.section == 0 && indexPath.row >= 5 && indexPath.row <= 8 {
            return indexPath
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath) { //点击列表项的处理
            if indexPath.section == 0 {
                switch indexPath.row{
                case 5:
                    Dialog().showDatePicker(NSLocalizedString("Set Focus Cycle Length", comment: "spl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.pomoTime), datePickerMode: .countDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
                        if setTimer != pomodoroClass.pomoTime {
                            pomodoroClass.pomoTime = setTimer
                            pomodoroClass.stop()
                        }
                        self.workLabel.text = self.updateDisplay(0)
                    }
                case 6:
                    Dialog().showDatePicker(NSLocalizedString("Set Break Length", comment: "sbl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.breakTime), datePickerMode: .countDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
                        if setTimer != pomodoroClass.breakTime {
                            pomodoroClass.breakTime = setTimer
                            pomodoroClass.stop()
                        }
                        self.breakLabel.text = self.updateDisplay(1)
                    }
                case 7:
                    Dialog().showDatePicker(NSLocalizedString("Set Long Break Length", comment: "slbl"), doneButtonTitle: NSLocalizedString("Done", comment: "done"), cancelButtonTitle: NSLocalizedString("Cancel", comment: "cancel"),defaultTime: Double(pomodoroClass.longBreakTime), datePickerMode: .countDownTimer) {
                        (timer) -> Void in
                        let setTimer = Int(timer - (timer.truncatingRemainder(dividingBy: 60)))
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
                        self.longBreakDelayLabel.text = "\(pomodoroClass.longBreakCount) " + NSLocalizedString("Focus Cycle", comment: "pd")
                    }
                default:break
                }
                
            }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController,
        didFinishWith result: MFMailComposeResult, error: Error?) {
            controller.dismiss(animated: true, completion: nil)
            
    }
    
    func updateDisplay(_ select:Int) -> String { //输出时间的文本表示
        var display = ""
        switch pomodoroClass.getStringOfTime(select) {
        case 1:display = pomodoroClass.timerLabelSec + " Sec"
        case 2:display = pomodoroClass.timerLabelMin + " " + NSLocalizedString("min", comment: "min")
        case 3:display = pomodoroClass.timerLabelHour + " " + NSLocalizedString("h", comment: "hour") + " " + pomodoroClass.timerLabelMin + " " + NSLocalizedString("min", comment: "min")
        default:break
        }
        return display
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

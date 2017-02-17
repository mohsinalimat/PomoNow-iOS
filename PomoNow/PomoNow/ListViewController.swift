//
//  ListViewController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/9.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class ListViewController: UIViewController ,UINavigationControllerDelegate{

    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var listContainer: UIView!
    @IBOutlet weak var statisticsContainer: UIView!
    @IBOutlet weak var settingsContainer: UIView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var barMaskView: UIView!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var statisticsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var unModeButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    @IBOutlet weak var notAvailableView: UIView!
    @IBOutlet weak var notAvailableLabel: UILabel!
    @IBOutlet weak var tipView: UIView!
    
    var background : CAGradientLayer? = nil
    var blurView: UIVisualEffectView? = nil
    var timer: Timer?
    var isChangedSizeClass = false
    
    @IBAction func popBack(_ sender: AnyObject) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func add(_ sender: AnyObject) {
        if barMaskView.alpha == 1 {
            accept(self)
        }
    }
    
    @IBAction func mode(_ sender: AnyObject) {
        modeButton.isHidden = true
        unModeButton.isHidden = false
        UIView.animate(withDuration: 0.2, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.modeButton.alpha = 0
            self.unModeButton.alpha = 1
        }) { (finish: Bool) -> Void in
        }
        addButton.isEnabled = false
        pomodoroTimer.stop()
        timeLabel.text = quickTimerClass.timerLabel
        isQuickTimerMode = true
        dataManagement.setDefaults("main.isQuickTimerMode" ,value: true as AnyObject)
        _ = navigationController?.popViewController(animated: true)
        ShortcutHelper().buildShortcut()
        isTip1Readed = true
        dataManagement.setDefaults("main.isTip1Readed", value: true as AnyObject)
    }
    
    @IBAction func unMode(_ sender: AnyObject) {
        unModeButton.isHidden = true
        modeButton.isHidden = false
        UIView.animate(withDuration: 0.2, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.modeButton.alpha = 1
            self.unModeButton.alpha = 0
            self.notAvailableView.alpha = 0
            self.notAvailableView.accessibilityElementsHidden = true
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.listContainer)
        }) { (finish: Bool) -> Void in
        }
        addButton.isEnabled = true
        quickTimerClass.stop(true)
        timeLabel.text = pomodoroTimer.timerLabel
        isQuickTimerMode = false
        dataManagement.setDefaults("main.isQuickTimerMode" ,value: false as AnyObject)
        ShortcutHelper().buildShortcut()
        listContainer.accessibilityElementsHidden = false
    }

    @IBAction func statistics(_ sender: AnyObject) {
        statisticsContainer.isHidden = false
        notAvailableLabel.isHidden = true
        modeButton.accessibilityElementsHidden = true
        statisticsButton.accessibilityElementsHidden = true
        settingsButton.accessibilityElementsHidden = true
        acceptButton.accessibilityElementsHidden = false
        listContainer.accessibilityElementsHidden = true
        settingsContainer.accessibilityElementsHidden = true
        statisticsContainer.accessibilityElementsHidden = false
        modeButton.accessibilityElementsHidden = true
        unModeButton.accessibilityElementsHidden = true
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, acceptButton)
        UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.statisticsContainer.alpha = 1
            self.barMaskView.alpha = 1
            self.tipView.alpha = 0
        }) { (finish: Bool) -> Void in
            self.statisticsButton.isHidden = true
            self.settingsButton.isHidden = true
        }
    }
    
    @IBAction func settings(_ sender: AnyObject) {
        settingsContainer.isHidden = false
        notAvailableLabel.isHidden = true
        modeButton.accessibilityElementsHidden = true
        statisticsButton.accessibilityElementsHidden = true
        settingsButton.accessibilityElementsHidden = true
        acceptButton.accessibilityElementsHidden = false
        listContainer.accessibilityElementsHidden = true
        statisticsContainer.accessibilityElementsHidden = true
        settingsContainer.accessibilityElementsHidden = false
        modeButton.accessibilityElementsHidden = true
        unModeButton.accessibilityElementsHidden = true
        if isiPad {
            performSegue(withIdentifier: "showSettings",sender:self)
        } else {
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, acceptButton)
            UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
                self.settingsContainer.alpha = 1
                self.barMaskView.alpha = 1
                self.tipView.alpha = 0
            }) { (finish: Bool) -> Void in
                self.statisticsButton.isHidden = true
                self.settingsButton.isHidden = true
            }
        }
    }
    
    @IBAction func accept(_ sender: AnyObject) {
        notAvailableLabel.isHidden = false
        statisticsButton.isHidden = false
        settingsButton.isHidden = false
        modeButton.accessibilityElementsHidden = false
        statisticsButton.accessibilityElementsHidden = false
        settingsButton.accessibilityElementsHidden = false
        acceptButton.accessibilityElementsHidden = true
        if notAvailableView.isHidden {
            listContainer.accessibilityElementsHidden = false
        }
        settingsContainer.accessibilityElementsHidden = true
        statisticsContainer.accessibilityElementsHidden = true
        modeButton.accessibilityElementsHidden = false
        unModeButton.accessibilityElementsHidden = false
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self.statisticsButton)
        UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.settingsContainer.alpha = 0
            if !isiPad {
                self.statisticsContainer.alpha = 0
            } else {
                if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact{
                    self.statisticsContainer.alpha = 0
                }
            }
            self.barMaskView.alpha = 0
            self.tipView.alpha = 1
        }) { (finish: Bool) -> Void in
            self.settingsContainer.isHidden = true
            if !isiPad {
                self.statisticsContainer.isHidden = true
            } else {
                if self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact{
                    self.statisticsContainer.isHidden = true
                }
            }
        }
    }
    
    @IBAction func tapTip1(_ sender: Any) {
        UIView.animate(withDuration: 0.3, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.tipView.alpha = 0
        }) { (finish: Bool) -> Void in
            self.tipView.isHidden = true
            isTip1Readed = true
            dataManagement.setDefaults("main.isTip1Readed", value: true as AnyObject)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.changeStyle), name: NSNotification.Name(rawValue: "changeStyle"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.clear), name: NSNotification.Name(rawValue: "clear"), object: nil)
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(ListViewController.timing), userInfo: nil, repeats: true)
        NotificationCenter.default.addObserver(self, selector: #selector(ListViewController.handleShortcut), name: NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
        timing()
        topView.backgroundColor = UIColor.clear
        settingsContainer.alpha = 0
        settingsContainer.isHidden = true
        barMaskView.alpha = 0
        
        if isiPad {
            if traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact{
                statisticsContainer.alpha = 0
                statisticsContainer.isHidden = true
                statisticsButton.isHidden = false
            } else {
                statisticsContainer.alpha = 1
                statisticsContainer.isHidden = false
                statisticsButton.isHidden = true
            }
        } else {
            statisticsContainer.alpha = 0
            statisticsContainer.isHidden = true
            statisticsButton.isHidden = false
        }
        
        if isQuickTimerMode {
            modeButton.alpha = 0
            modeButton.isHidden = true
            addButton.isEnabled = false
            notAvailableLabel.text = NSLocalizedString("Not available in quick timer mode",comment:"Not available in quick timer mode")
            notAvailableView.alpha = 1
            listContainer.accessibilityElementsHidden = true
        } else {
            unModeButton.alpha = 0
            unModeButton.isHidden = true
            notAvailableView.alpha = 0
            listContainer.accessibilityElementsHidden = false
        }
        
        //判断 Tip 显示状态
        if isTip1Readed {
            tipView.isHidden = true
        }
        
        //无障碍设定
        tipView.accessibilityElementsHidden = true
        
        background = turquoiseColor() //设置背景
        background!.frame.size.height = view.bounds.height
        background!.frame.size.width = view.bounds.width
        view.layer.insertSublayer(background!, at: 0)
        
        setStyleMode()
        
        //毛玻璃叠层
        let blurEffect = UIBlurEffect(style: .dark)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView!.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        notAvailableView.insertSubview(blurView!, belowSubview: notAvailableLabel)
        
        //叠层Autolayout
        blurView!.translatesAutoresizingMaskIntoConstraints = false
        let blurViewConstraintX = NSLayoutConstraint(item: blurView!,
                                                     attribute: NSLayoutAttribute.centerX,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: notAvailableView,
                                                     attribute: NSLayoutAttribute.centerX,
                                                     multiplier: 1.0,
                                                     constant: 0)
        notAvailableView.addConstraint(blurViewConstraintX)
        let blurViewConstraintY = NSLayoutConstraint(item: blurView!,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: notAvailableView,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     multiplier: 1.0,
                                                     constant: 0)
        notAvailableView.addConstraint(blurViewConstraintY)
        let blurViewConstraintWidth = NSLayoutConstraint(item: blurView!,
                                                         attribute: NSLayoutAttribute.width,
                                                         relatedBy: NSLayoutRelation.equal,
                                                         toItem: notAvailableView,
                                                         attribute: NSLayoutAttribute.width,
                                                         multiplier: 1.0,
                                                         constant: 0)
        notAvailableView.addConstraint(blurViewConstraintWidth)
        let blurViewConstraintHeight = NSLayoutConstraint(item: blurView!,
                                                          attribute: NSLayoutAttribute.height,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: notAvailableView,
                                                          attribute: NSLayoutAttribute.height,
                                                          multiplier: 1.0,
                                                          constant: 0)
        notAvailableView.addConstraint(blurViewConstraintHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        handleShortcut()
    }
    
    func handleShortcut() {
        //接收 3DTouch 消息
        if isCallByShortcut {
            switch callType {
            case "AddTask":
                add(self)
                isCallByShortcut = false
            case "QuickTimer Mode":
                popBack(self)
            case "Pomodoro Mode":
                popBack(self)
            case "TaskList":
                isCallByShortcut = false
            case "SetTask":
                popBack(self)
            default:
                break
            }
        }
    }
    
    func clear() {//在列表为空时显示遮挡View
        notAvailableLabel.text = NSLocalizedString("No task for today",comment:"No task for today")
        UIView.animate(withDuration: 0.2, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.notAvailableView.alpha = 1
        }) { (finish: Bool) -> Void in
        }
    }
    
    func changeStyle() {
        UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.setStyleMode()
        }) { (finish: Bool) -> Void in
        }
    }
    
    func setStyleMode() { //UI风格变换
        if isDarkMode {
            background!.isHidden = true
            view.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            timeLabel.textColor = UIColor(red: 0.949, green: 0.3373, blue: 0.2824, alpha: 1.0)
            addButton.setImage(UIImage(named: "AddDark"), for: UIControlState())
            barView.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            barMaskView.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
            notAvailableLabel.textColor = UIColor(red: 0.728, green: 0.728, blue: 0.728, alpha: 1.0)
            blurView?.effect = UIBlurEffect(style: .dark)
        } else {
            background!.isHidden = false
            timeLabel.textColor = UIColor.white
            addButton.setImage(UIImage(named: "Add"), for: UIControlState())
            barView.backgroundColor = UIColor.white
            barMaskView.backgroundColor = UIColor.white
            notAvailableLabel.textColor = UIColor(red:0.4549, green:0.4549, blue:0.4549, alpha:1.0)
            blurView?.effect = UIBlurEffect(style: .light)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
        if isiPad {
            if barMaskView.alpha == 0 {
                if traitCollection.horizontalSizeClass == UIUserInterfaceSizeClass.compact{
                    statisticsContainer.alpha = 0
                    statisticsButton.isHidden = false
                    isChangedSizeClass = true
                } else {
                    if isChangedSizeClass {
                        statisticsContainer.alpha = 1
                        statisticsButton.isHidden = true
                        isChangedSizeClass = false
                    }
                }
            }
        }
        dilogWidth = topView.frame.width //在布局发生改变的时存储屏幕宽度保证分屏显示效果
    }

    func turquoiseColor() -> CAGradientLayer { //渐变色层
        let topColor = UIColor(red:0.9725, green:0.3843, blue:0.3333, alpha:1.0)
        let bottomColor = UIColor(red:0.9529, green:0.3412, blue:0.3255, alpha:1.0)
        let gradientColors: Array <AnyObject> = [topColor.cgColor, bottomColor.cgColor]
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        
        gradientLayer.colors = gradientColors
        let gradientLocations: Array <NSNumber> = [0.0, 1.0]
        
        gradientLayer.locations = gradientLocations
        
        return gradientLayer
    }
    
    func timing() {
        if isQuickTimerMode {
            timeLabel.text = quickTimerClass.timerLabel
            timeLabel.accessibilityLabel = NSLocalizedString("Tap here back to the timer",comment:"Tap here back to the timer") + quickTimerClass.timerAccessibilityLabel
        } else {
            timeLabel.text = pomodoroTimer.timerLabel
            timeLabel.accessibilityLabel = NSLocalizedString("Tap here back to the timer",comment:"Tap here back to the timer") + pomodoroTimer.timerAccessibilityLabel
        }
    }
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.pop {
            return AnimationFromList()
        } else {
            return nil
        }
    }

}

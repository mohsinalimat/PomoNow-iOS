//
//  MainViewController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/7.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit
import QuartzCore
import UserNotifications

class MainViewController: UIViewController ,UINavigationControllerDelegate{

    @IBOutlet weak var pomodoroView: UIView!
    @IBOutlet weak var quickTimerView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var gesterRecognizer: UIView!
    
    var blurView: UIVisualEffectView? = nil
    var background: CAGradientLayer? = nil
    var timerGestureView: CProgressView? = nil
    var vibrancyView: UIVisualEffectView? = nil
    var timer: Timer? = nil
        
    @IBAction func startGesture(_ sender: UILongPressGestureRecognizer) {     
        if pomodoroTimer.pomoMode == 0 {
            if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled {
                pomodoroTimer.stopSound()
                if timerGestureView!.valueProgress < 100 {
                    processToZero()
                } else {
                    hideGestureView()
                    pomodoroTimer.start()
                    timer = nil
                    timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(MainViewController.timing), userInfo: nil, repeats: true)

                }
            } else if sender.state == UIGestureRecognizerState.began {
                if pomodoroTimer.pomoMode == 0 {
                    pomodoroTimer.playSound(1)
                    showGestureView()
                    processToFull()
                }
            }
        } else {
            if sender.state == UIGestureRecognizerState.ended || sender.state == UIGestureRecognizerState.cancelled{
                hideGestureView()
            } else if sender.state == UIGestureRecognizerState.began {
                showGestureView()
            }
        }
    }

    @IBAction func stopGesture(_ sender: AnyObject) {
        pomodoroTimer.stop()
        timerGestureView!.valueProgress = 0
        
    }
    
    @IBAction func toList(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "showList",sender:self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        navigationController?.delegate = self
        //判断计时模式并修改UI状态
        if isQuickTimerMode {
            gestureView!.isHidden = true
            gesterRecognizer!.isHidden = true
            quickTimerView.isHidden = false
            pomodoroView.isHidden = true
        } else {
            quickTimerView.isHidden = true
            pomodoroView.isHidden = false
            gesterRecognizer!.isHidden = false
        }
        handleShortcut()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //停止计时的通知接收
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.pomodoroStopped), name: NSNotification.Name(rawValue: "PomodoroStopped"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(MainViewController.handleShortcut), name: NSNotification.Name.UIApplicationDidBecomeActive, object:nil)
        
        if dataManagement.getDefaults("main.isFirst2.0") != nil {  //存储默认设置
            isFirst = dataManagement.getDefaults("main.isFirst2.0") as? Bool ?? true
            isDarkMode = dataManagement.getDefaults("main.isDarkMode") as? Bool ?? false
            isQuickTimerMode = dataManagement.getDefaults("main.isQuickTimerMode") as? Bool ?? false
            isDisableLockScreen = dataManagement.getDefaults("main.isDisableLockScreen") as? Bool ?? false
            isTip1Readed = dataManagement.getDefaults("main.isTip1Readed") as? Bool ?? false
            isTip2Readed = dataManagement.getDefaults("main.isTip2Readed") as? Bool ?? false
        } else {
            dataManagement.setDefaults ("main.isFirst2.0",value: true as AnyObject)
            dataManagement.setDefaults("main.isDarkMode" ,value: false as AnyObject)
            dataManagement.setDefaults("main.isQuickTimerMode" ,value: false as AnyObject)
            dataManagement.setDefaults ("main.isDisableLockScreen",value: false as AnyObject)
            dataManagement.setDefaults("main.isTip1Readed", value: false as AnyObject)
            dataManagement.setDefaults("main.isTip2Readed", value: false as AnyObject)
        }
        //禁用锁定屏幕
        let app = UIApplication.shared
        app.isIdleTimerDisabled = isDisableLockScreen
        
        gestureView.isHidden = true
        timerGestureView?.alpha = 0
        
        background = turquoiseColor() //设置背景
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
        view.layer.insertSublayer(background!, at: 0)
        
        //毛玻璃叠层
        blurView = UIVisualEffectView(effect: nil)
        blurView!.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        gestureView.addSubview(blurView!)
        
        //叠层Autolayout
        blurView!.translatesAutoresizingMaskIntoConstraints = false
        let blurViewConstraintX = NSLayoutConstraint(item: blurView!,
                                                    attribute: NSLayoutAttribute.centerX,
                                                    relatedBy: NSLayoutRelation.equal,
                                                    toItem: gestureView,
                                                    attribute: NSLayoutAttribute.centerX,
                                                    multiplier: 1.0,
                                                    constant: 0)
        gestureView.addConstraint(blurViewConstraintX)
        let blurViewConstraintY = NSLayoutConstraint(item: blurView!,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: gestureView,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     multiplier: 1.0,
                                                     constant: 0)
        gestureView.addConstraint(blurViewConstraintY)
        let blurViewConstraintWidth = NSLayoutConstraint(item: blurView!,
                                                     attribute: NSLayoutAttribute.width,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: gestureView,
                                                     attribute: NSLayoutAttribute.width,
                                                     multiplier: 1.0,
                                                     constant: 0)
        gestureView.addConstraint(blurViewConstraintWidth)
        let blurViewConstraintHeight = NSLayoutConstraint(item: blurView!,
                                                         attribute: NSLayoutAttribute.height,
                                                         relatedBy: NSLayoutRelation.equal,
                                                         toItem: gestureView,
                                                         attribute: NSLayoutAttribute.height,
                                                         multiplier: 1.0,
                                                         constant: 0)
        gestureView.addConstraint(blurViewConstraintHeight)
        
        //创建并添加vibrancy视图
        vibrancyView = UIVisualEffectView(effect: UIVibrancyEffect(blurEffect: UIBlurEffect(style: .dark)))
        vibrancyView!.frame.size = CGSize(width: view.frame.width, height: view.frame.height)
        blurView!.contentView.addSubview(vibrancyView!)
        timerGestureView = CProgressView(frame: CGRect(x: view.frame.width/2 - view.frame.width/3,y: view.frame.height/2 - view.frame.width/3, width: view.frame.width/3 * 2, height: view.frame.width/3 * 2))
        timerGestureView!.isOpaque = false
        timerGestureView!.backgroundColor = UIColor.clear
        timerGestureView!.circleColor = UIColor.gray
        timerGestureView!.progressColor = UIColor.white
        timerGestureView!.lineWidth = 10
        
        //vibrancy视图Autolayout
        vibrancyView!.translatesAutoresizingMaskIntoConstraints = false
        timerGestureView!.translatesAutoresizingMaskIntoConstraints = false
        let vibrancyViewConstraintX = NSLayoutConstraint(item: vibrancyView!,
                                                     attribute: NSLayoutAttribute.centerX,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: blurView!,
                                                     attribute: NSLayoutAttribute.centerX,
                                                     multiplier: 1.0,
                                                     constant: 0)
        gestureView.addConstraint(vibrancyViewConstraintX)
        let vibrancyViewConstraintY = NSLayoutConstraint(item: vibrancyView!,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     relatedBy: NSLayoutRelation.equal,
                                                     toItem: blurView!,
                                                     attribute: NSLayoutAttribute.centerY,
                                                     multiplier: 1.0,
                                                     constant: 0)
        gestureView.addConstraint(vibrancyViewConstraintY)
        let vibrancyViewConstraintWidth = NSLayoutConstraint(item: vibrancyView!,
                                                         attribute: NSLayoutAttribute.width,
                                                         relatedBy: NSLayoutRelation.equal,
                                                         toItem: blurView!,
                                                         attribute: NSLayoutAttribute.width,
                                                         multiplier: 1.0,
                                                         constant: 0)
        gestureView.addConstraint(vibrancyViewConstraintWidth)
        let vibrancyViewConstraintHeight = NSLayoutConstraint(item: vibrancyView!,
                                                          attribute: NSLayoutAttribute.height,
                                                          relatedBy: NSLayoutRelation.equal,
                                                          toItem: blurView!,
                                                          attribute: NSLayoutAttribute.height,
                                                          multiplier: 1.0,
                                                          constant: 0)
        gestureView.addConstraint(vibrancyViewConstraintHeight)
        //更新计时器位置
        updateUIAfterActive()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateUIAfterActive()
        setStyleMode()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    func setStyleMode() { //UI风格变换
        if isDarkMode {
            background!.isHidden = true
            view.backgroundColor = UIColor(red:0.1451, green:0.1451, blue:0.1451, alpha:1.0)
        } else {
            background!.isHidden = false
        }
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
    
    //解决分屏时计时器的尺寸问题
    func updateUIAfterActive() {
        timerGestureView!.removeFromSuperview()
        vibrancyView!.contentView.addSubview(timerGestureView!)
        let timerGestureViewConstraintX = NSLayoutConstraint(item: timerGestureView!,
                                                             attribute: NSLayoutAttribute.centerX,
                                                             relatedBy: NSLayoutRelation.equal,
                                                             toItem: vibrancyView,
                                                             attribute: NSLayoutAttribute.centerX,
                                                             multiplier: 1.0,
                                                             constant: 0)
        vibrancyView!.addConstraint(timerGestureViewConstraintX)
        let timerGestureViewConstraintY = NSLayoutConstraint(item: timerGestureView!,
                                                             attribute: NSLayoutAttribute.centerY,
                                                             relatedBy: NSLayoutRelation.equal,
                                                             toItem: vibrancyView,
                                                             attribute: NSLayoutAttribute.centerY,
                                                             multiplier: 1.0,
                                                             constant: 0)
        vibrancyView!.addConstraint(timerGestureViewConstraintY)
        var timerGestureViewWidth: CGFloat = 0
        if view.frame.width < view.frame.height {
            timerGestureViewWidth = view.frame.width * 0.6
        } else {
            timerGestureViewWidth = view.frame.height * 0.6
        }
        let timerGestureViewConstraintWidth = NSLayoutConstraint(item: timerGestureView!,
                                                                 attribute: NSLayoutAttribute.width,
                                                                 relatedBy: NSLayoutRelation.equal,
                                                                 toItem: nil,
                                                                 attribute: NSLayoutAttribute.height,
                                                                 multiplier: 1,
                                                                 constant: timerGestureViewWidth)
        gestureView.addConstraint(timerGestureViewConstraintWidth)
        let timerGestureViewConstraintHeight = NSLayoutConstraint(item: timerGestureView!,
                                                                  attribute: NSLayoutAttribute.height,
                                                                  relatedBy: NSLayoutRelation.equal,
                                                                  toItem: gestureView,
                                                                  attribute: NSLayoutAttribute.height,
                                                                  multiplier: 0.6,
                                                                  constant: 0)
        gestureView.addConstraint(timerGestureViewConstraintHeight)
        
        background!.frame.size.height = view.bounds.height + 500
        background!.frame.size.width = view.bounds.width + 500
    }
    
    func timing() { //预览计时进度
        timerGestureView!.valueProgress = pomodoroTimer.process
        timerGestureView!.setNeedsDisplay()
    }
    
    //动画部分
    var aniMode = true //填充进程false 还是收回进程true
    func processToZero() { //更新进度条状态
        stopTimer()
        aniMode = true
        timer = Timer.scheduledTimer(timeInterval: 0.013, target: self, selector: #selector(MainViewController.processAnimation(_:)), userInfo: nil, repeats: true)
    }
    
    func processToFull() {
        stopTimer()
        aniMode = false
        timer = Timer.scheduledTimer(timeInterval: 0.013, target: self, selector: #selector(MainViewController.processAnimation(_:)), userInfo: nil, repeats: true)
    }
    
    func processAnimation(_ timer: Timer) { //处理进度条动画
        if aniMode {
            if timerGestureView!.valueProgress > 0 {
                timerGestureView!.valueProgress -= 1
            }else {
                timerGestureView!.valueProgress = 0
                stopTimer()
                hideGestureView()
            }
        } else {
            if timerGestureView!.valueProgress < 100 {
                timerGestureView!.valueProgress += 1
            }else {
                timerGestureView!.valueProgress = 100
                stopTimer()
            }
        }
    }
    
    func stopTimer() { //停止动画计时器
        timer?.invalidate()
        timer = nil
    }
    
    func pomodoroStopped() { //计时器复位
        timerGestureView!.valueProgress = 0
        timerGestureView!.setNeedsDisplay()
        stopTimer()
        hideGestureView()
    }
    
    func showGestureView() {
        gestureView.isHidden = false
        UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.blurView?.effect = UIBlurEffect(style: .dark)
            self.timerGestureView?.alpha = 1
        }) { (finish: Bool) -> Void in
        } //显示进度条
    }
    
    func hideGestureView() {
        UIView.animate(withDuration: 0.5, delay:0,options:UIViewAnimationOptions.beginFromCurrentState,  animations: { () -> Void in
            self.blurView?.effect = nil
            self.timerGestureView?.alpha = 0
        }) { (finish: Bool) -> Void in
            if self.aniMode {
                self.gestureView.isHidden = true
            }
            
        }//隐藏进度条
    }
    
    func handleShortcut() {
        //接收 3DTouch 消息
        if (self.view.window != nil) {
            if isCallByShortcut {
                switch callType {
                case "AddTask":
                    isQuickTimerMode = false
                    dataManagement.setDefaults("main.isQuickTimerMode" ,value: false as AnyObject)
                    performSegue(withIdentifier: "showList",sender:self)
                    ShortcutHelper().buildShortcut()
                case "QuickTimer Mode":
                    isQuickTimerMode = true
                    dataManagement.setDefaults("main.isQuickTimerMode" ,value: true as AnyObject)
                    gestureView!.isHidden = true
                    gesterRecognizer!.isHidden = true
                    quickTimerView.isHidden = false
                    isCallByShortcut = false
                    pomodoroTimer.stop()
                    ShortcutHelper().buildShortcut()
                case "Pomodoro Mode":
                    isQuickTimerMode = false
                    dataManagement.setDefaults("main.isQuickTimerMode" ,value: false as AnyObject)
                    gesterRecognizer!.isHidden = false
                    quickTimerView.isHidden = true
                    isCallByShortcut = false
                    quickTimerClass.stop(true)
                    ShortcutHelper().buildShortcut()
                case "TaskList":
                    if !quickTimerClass.timing {
                        isQuickTimerMode = false
                        dataManagement.setDefaults("main.isQuickTimerMode" ,value: false as AnyObject)
                        gesterRecognizer!.isHidden = false
                        quickTimerView.isHidden = true
                        ShortcutHelper().buildShortcut()
                    }
                    isCallByShortcut = false
                    performSegue(withIdentifier: "showList",sender:self)
                case "SetTask":
                    isCallByShortcut = false
                default:
                    break
                }
            }
        }
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask { //处理屏幕旋转问题
        if isiPad {
            return [UIInterfaceOrientationMask.portrait,UIInterfaceOrientationMask.landscape ,UIInterfaceOrientationMask.portraitUpsideDown]
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }
    
    override var shouldAutorotate : Bool { //在iPhone上固定屏幕旋转
        if isiPad {
            return true
        } else {
            return false
        }
    }
        
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationControllerOperation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        if operation == UINavigationControllerOperation.push {
            return AnimationToList()
        } else {
            return nil
        }
    }
}

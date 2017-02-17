//
//  AnimationToList.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/9.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class AnimationToList: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 1.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //获取View的上下文
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! MainViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! ListViewController
        let container = transitionContext.containerView
        
        toVC.view.alpha = 0
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        container.addSubview(toVC.view)
        
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height
        
        let mask = UIView(frame:CGRect(origin: CGPoint(x: 0,y: screenHeight), size: CGSize(width: screenWidth, height: screenHeight))) //遮挡view
        if isDarkMode {
            mask.backgroundColor = UIColor(red:0.1922, green:0.1922, blue:0.1922, alpha:1.0)
        } else {
            mask.backgroundColor = UIColor.white
        }
        
        container.addSubview(mask)
        
        toVC.view.layoutIfNeeded() //获取正确的目标位置
        let topViewFrame = container.convert(toVC.topView.frame, from: fromVC.view)
        
        var QuickTimerViewNeesSetAlpha = false
        
        //动画序列
        if isQuickTimerMode {
            fromVC.pomodoroView.alpha = 0
        }
        UIView.animate(withDuration: 0.1, delay:0,options:UIViewAnimationOptions(),  animations: { () -> Void in
            if fromVC.quickTimerView.alpha == 1 {
                fromVC.quickTimerView.alpha = 0
                QuickTimerViewNeesSetAlpha = true
            }
            fromVC.pomodoroView.alpha = 0
        }) { (finish: Bool) -> Void in
        }
        UIView.animate(withDuration: 0.3, delay:0.1,options:UIViewAnimationOptions(),  animations: { () -> Void in
            mask.frame = CGRect(x: 0, y: topViewFrame.height + topViewFrame.origin.y, width: screenWidth, height: screenHeight)
        }) { (finish: Bool) -> Void in
        }
        if isQuickTimerMode {
            toVC.timeLabel.text = quickTimerClass.timerLabel
        } else {
            toVC.timeLabel.text = pomodoroTimer.timerLabel
        }
        toVC.setStyleMode()
        fromVC.setStyleMode()
        UIView.animate(withDuration: 0.1, delay:0.4,options:UIViewAnimationOptions(),  animations: { () -> Void in
            toVC.view.alpha = 1
        }) { (finish: Bool) -> Void in
        }
        UIView.animate(withDuration: 0.1, delay:0.5,options:UIViewAnimationOptions(),  animations: { () -> Void in
            mask.alpha = 0
        }) { (finish: Bool) -> Void in
            fromVC.pomodoroView.alpha = 1
            if QuickTimerViewNeesSetAlpha {
                fromVC.quickTimerView.alpha = 1
            }
            mask.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
    }
}

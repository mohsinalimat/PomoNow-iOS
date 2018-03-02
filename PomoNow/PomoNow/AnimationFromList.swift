//
//  AnimationFromList.swift
//  PomoNow
//
//  Created by Megabits on 15/10/2.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
//

import UIKit

class AnimationFromList: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //获取动画的源控制器和目标控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! PomoListViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! PomodoroViewController
        let container = transitionContext.containerView
        

        
        let snap = fromVC.TimerView.snapshotView(afterScreenUpdates: false)
        snap?.frame = container.convert(fromVC.TimerView.frame, from: fromVC.view)
        
        let snapRound = fromVC.round.snapshotView(afterScreenUpdates: false)
        snapRound?.frame = container.convert(fromVC.round.frame, from: fromVC.view)
        
        fromVC.TimerView.isHidden = true
        snapRound?.alpha = 0
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        toVC.view.alpha = 0
        
        //代理管理以下view
        container.addSubview(snap!)
        container.addSubview(snapRound!)
        container.addSubview(toVC.view)
        
        UIView.animate(withDuration: 0.1, delay:0,options:UIViewAnimationOptions(),  animations: { () -> Void in
            fromVC.ListContainer.alpha = 0
            }) { (finish: Bool) -> Void in
                fromVC.round.isHidden = true
                snapRound?.alpha = 1
                toVC.timeLabel.text = pomodoroClass.timerLabel
                if withTask {
                    if task.count > 0 {
                        for i in 0...task.count - 1 {
                            if task[i][3] == "1" {
                                toVC.taskLabel.text = task[i][1]
                            }
                        }
                    } else {
                        withTask = false
                        toVC.setDefaults ("main.withTask",value: withTask as AnyObject)
                    }
                } else {
                    toVC.taskLabel.text = NSLocalizedString("Start with a task", comment: "Start with a task")
                }
        }
        
        UIView.animate(withDuration: 0.25, delay:0.1,options:UIViewAnimationOptions(),  animations: { () -> Void in
            toVC.view.layoutIfNeeded()
            toVC.view.setNeedsDisplay()
            snapRound?.frame = toVC.round.frame
            snap?.frame = container.convert(toVC.TimerView.frame, from: toVC.TimerViewContainer)
            }) { (finish: Bool) -> Void in
        }
        
        UIView.animate(withDuration: 0.1, delay:0.4,options:UIViewAnimationOptions(),  animations: { () -> Void in
            snapRound?.alpha = 0
            snap?.alpha = 0
            }) { (finish: Bool) -> Void in
                snap?.removeFromSuperview()
                snapRound?.removeFromSuperview()
        }
        
        UIView.animate(withDuration: 0.05, delay:0.35,options:UIViewAnimationOptions(),  animations: { () -> Void in
            toVC.view.alpha = 1
            }) { (finish: Bool) -> Void in
                transitionContext.completeTransition(true)
        }
        
    }
}

//
//  MagicMoveTransion.swift
//  PomoNow
//
//  Created by Megabits on 15/7/13.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
//

import UIKit

class AnimationToList: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        //获取动画的源控制器和目标控制器
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! PomodoroViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! PomoListViewController
        let container = transitionContext.containerView
        
        let snap = fromVC.TimerView.snapshotView(afterScreenUpdates: false)
        snap?.frame = container.convert(fromVC.TimerView.frame, from: fromVC.TimerViewContainer)
        
        let snapRound = fromVC.round.snapshotView(afterScreenUpdates: false)
        snapRound?.frame = container.convert(fromVC.round.frame, from: fromVC.view)
        
        fromVC.TimerView.isHidden = true
        
        toVC.view.frame = transitionContext.finalFrame(for: toVC)
        toVC.view.alpha = 0
        snapRound?.alpha = 0
        

        //代理管理以下view
        container.addSubview(snap!)
        container.addSubview(snapRound!)
        container.addSubview(toVC.view)
        
        UIView.animate(withDuration: 0.1, delay:0,options:UIViewAnimationOptions(),  animations: { () -> Void in
            fromVC.taskLabel.alpha = 0
            fromVC.readme.alpha = 0
            }) { (finish: Bool) -> Void in
                fromVC.round.isHidden = true
                snapRound?.alpha = 1
        }
        
        UIView.animate(withDuration: 0.25, delay:0.1,options:UIViewAnimationOptions(),  animations: { () -> Void in
            toVC.view.layoutIfNeeded()
            toVC.view.setNeedsDisplay()
            snapRound?.frame = toVC.round.frame
            snap?.frame = toVC.TimerView.frame
            }) { (finish: Bool) -> Void in
        }
        
        UIView.animate(withDuration: 0.25, delay:0.8,options:UIViewAnimationOptions(),  animations: { () -> Void in
            snap?.alpha = 0
            }) { (finish: Bool) -> Void in
        }
        UIView.animate(withDuration: 0.15, delay:0.35,options:UIViewAnimationOptions(),  animations: { () -> Void in
            snapRound?.alpha = 0
            toVC.view.alpha = 1
            }) { (finish: Bool) -> Void in
            //让系统管理 navigation
            fromVC.TimerView.isHidden = false
            fromVC.round.isHidden = false
            fromVC.taskLabel.alpha = 1
            fromVC.readme.alpha = 1
            snap?.removeFromSuperview()
            snapRound?.removeFromSuperview()
            transitionContext.completeTransition(true)
        }
        
    }
}

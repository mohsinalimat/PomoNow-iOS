//
//  AnimationFromList.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/9.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class AnimationFromList: NSObject, UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! ListViewController
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) as! MainViewController
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
        toVC.setStyleMode()

        fromVC.view.layoutIfNeeded() //获取正确的目标位置
        let topViewFrame = container.convert(fromVC.topView.frame, from: fromVC.view)
        mask.frame = CGRect(x: 0, y: topViewFrame.height + topViewFrame.origin.y, width: screenWidth, height: screenHeight)
        mask.alpha = 0
        
        //动画序列
        UIView.animate(withDuration: 0.1, delay:0,options:UIViewAnimationOptions(),  animations: { () -> Void in
            mask.alpha = 1
        }) { (finish: Bool) -> Void in
        }
        UIView.animate(withDuration: 0.1, delay:0.1,options:UIViewAnimationOptions(),  animations: { () -> Void in
            fromVC.topView.alpha = 0
            fromVC.listContainer.alpha = 0
            fromVC.settingsContainer.alpha = 0
            fromVC.statisticsContainer.alpha = 0
            fromVC.barView.alpha = 0
            fromVC.notAvailableView.alpha = 0
        }) { (finish: Bool) -> Void in
        }
        UIView.animate(withDuration: 0.3, delay:0.2,options:UIViewAnimationOptions(),  animations: { () -> Void in
            mask.frame = CGRect(x: 0, y: screenHeight , width: screenWidth, height: screenHeight)
        }) { (finish: Bool) -> Void in
        }
        //判断计时模式并修改UI状态
        if isQuickTimerMode {
            toVC.gestureView!.isHidden = true
            toVC.gesterRecognizer!.isHidden = true
            toVC.quickTimerView.isHidden = false
        } else {
            toVC.quickTimerView.isHidden = true
            toVC.gestureView!.isHidden = true
            toVC.gesterRecognizer!.isHidden = false
        }
        UIView.animate(withDuration: 0.1, delay:0.4,options:UIViewAnimationOptions(),  animations: { () -> Void in
            toVC.view.alpha = 1
        }) { (finish: Bool) -> Void in
            fromVC.topView.alpha = 1
            fromVC.notAvailableView.alpha = 1
            mask.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

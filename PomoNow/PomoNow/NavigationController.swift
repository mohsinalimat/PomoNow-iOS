//
//  NavigationController.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/8/7.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if (UIDevice.current.userInterfaceIdiom != .phone) {
            isiPad = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask { //处理屏幕旋转问题
        if isiPad {
            return [UIInterfaceOrientationMask.portrait,UIInterfaceOrientationMask.landscape ,UIInterfaceOrientationMask.portraitUpsideDown]
        } else {
            return UIInterfaceOrientationMask.portrait
        }
    }

}

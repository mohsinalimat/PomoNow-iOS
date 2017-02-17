//
//  ShortcutHelper.swift
//  PomoNow
//
//  Created by 孟金羽 on 2016/9/22.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

class ShortcutHelper :NSObject {
    func buildShortcut() {
        // 创建 3DTouch 快捷操作
        let addItem = UIApplicationShortcutItem(type: "AddTask", localizedTitle: "Add task", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .add), userInfo: nil)
        var modeSwitch = UIApplicationShortcutItem(type: "QuickTimer Mode", localizedTitle: "QuickTimer Mode", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .alarm), userInfo: nil)
        if isQuickTimerMode {
            modeSwitch = UIApplicationShortcutItem(type: "Pomodoro Mode", localizedTitle: "Pomodoro Mode", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .time), userInfo: nil)
        }
        
        // 将标签添加进Application的shortcutItems中
        UIApplication.shared.shortcutItems = [addItem,modeSwitch]
    }
}

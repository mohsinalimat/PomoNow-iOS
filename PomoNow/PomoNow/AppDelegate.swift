//
//  AppDelegate.swift
//  PomoNow
//
//  Created by 孟金羽 on 16/6/21.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

//一些全局参数
var isFirst = true
var finishFirstPomodoro = false
var isTip1Readed = false
var isTip2Readed = false
var isDarkMode = false
var isQuickTimerMode = false
var isDisableLockScreen = false
var isiPad = false
var dilogWidth:CGFloat = 0.0
var isCallByShortcut = false
var callType:String = ""

let pomodoroTimer = pomodoro()
let quickTimerClass = quickTimer()
var dataManagement = DataManagement()

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: { granted, error in })
        } else {
            var categories = Set<UIUserNotificationCategory>()
            let inviteCategory = UIMutableUserNotificationCategory()
            inviteCategory.identifier = "com.JinyuMeng.pomodoro"
            categories.insert(inviteCategory)
            application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.sound, .alert, .badge], categories: categories))
        }
        
        ShortcutHelper().buildShortcut()
        return true
    }
    
    //处理 3DTouch
    func handleShortcut(shortcutItem:UIApplicationShortcutItem) -> Bool {
        callType = shortcutItem.type
        isCallByShortcut = true
        return true
    }
    
    func application(_ application: UIApplication,performActionFor shortcutItem: UIApplicationShortcutItem,completionHandler: @escaping (Bool) -> Void) {
        completionHandler(handleShortcut(shortcutItem: shortcutItem))
        
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        //处理 URL 调用
        let urlString = url.absoluteString
        
        switch urlString {
        case "PomoNow://tasks":
            callType = "TaskList"
            isCallByShortcut = true
        case "PomoNow://addTask":
            callType = "AddTask"
            isCallByShortcut = true
        default:
            break
        }
        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            application.applicationIconBadgeNumber = 1
            application.applicationIconBadgeNumber = 0
            application.cancelAllLocalNotifications()
        }
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        } else {
            application.applicationIconBadgeNumber = 1
            application.applicationIconBadgeNumber = 0
            application.cancelAllLocalNotifications()
        }
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        
    }
}


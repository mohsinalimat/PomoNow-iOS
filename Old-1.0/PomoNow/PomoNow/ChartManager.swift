//
//  ChartManager.swift
//  PomoNow
//
//  Created by Megabits on 15/11/25.
//  Copyright © 2015年 ScrewBox. All rights reserved.
//

import Foundation
import SwiftDate

class ChartManager :NSObject{
    var chart = [[Int]]()
    var dates = [String]()
    var today = NSDate.today()
    var thisWeekDays:Int = 7
    private var timer: NSTimer?
    
    var year:Int = 0
    var month:Int = 0
    var thisweek = [0,0]
    var lastweek = [0,0]
    var todays = [0,0]
    
    override init() {
        super.init()
        chart = [[0,0],[0,0],[0,0],[0,0],[0,0],[0,0],[0,0]]//[数据，启用]
        dates = ["","","","","","",""]
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(ChartManager.getToday(_:)), userInfo: nil, repeats: true)
        let weekday = today.weekday
        let thisSunday = today-(weekday - 1).day
        var thisDay = thisSunday
        if getDefaults("main.chart") != nil {
            chart = getDefaults("main.chart") as? Array<Array<Int>> ?? [[Int]]()
            dates = getDefaults("main.dates") as? Array<String> ?? [String]()
        } else {
            for i in 0...6 {
                thisDay = thisSunday+i.day
                dates[i] = thisDay.toString(format: DateFormat.Custom("YYYY-MM-DD"))
            }
            setDefaults ("main.chart",value: chart)
            setDefaults ("main.dates",value: dates)
        }
        //测试数据
//        chart = [[10,1],[5,1],[12,1],[9,0],[5,0],[6,0],[12,0]]//[数据，启用]
        
        if getDefaults("number.todays") != nil {
            todays = getDefaults("number.todays") as? Array<Int> ?? [0,0]
            thisweek = getDefaults("number.thisweek") as? Array<Int> ?? [0,0]
            lastweek = getDefaults("number.lastweek") as? Array<Int> ?? [0,0]
            month = getDefaults("number.month") as? Int ?? 0
            year = getDefaults("number.year") as? Int ?? 0
        } else {
            for i in 0...thisWeekDays-1 {
                thisweek[0] += chart[i][0]
            }
            setDefaults("number.year",value: year)
            setDefaults("number.month", value: month)
            setDefaults("number.lastweek", value: lastweek)
            setDefaults("number.thisweek", value: thisweek)
            setDefaults("number.todays", value: todays)
            setDefaults("main.today",value: today)
        }
        updateData()
    }
    
    func updateData() {
        let weekday = today.weekday
        let thisSunday = today-(weekday - 1).day
        var thisDay = thisSunday
        
        //初始化统计图数据
        if NSDate.date(fromString: dates[weekday - 1], format: DateFormat.Custom("YYYY-MM-DD")) != today {
            dates[weekday - 1] = today.toString(format: DateFormat.Custom("YYYY-MM-DD"))
            chart[weekday - 1] = [0,1]
            todays = [0,0]
            setDefaults("number.todays", value: todays)
        }
        todays[0] = chart[weekday - 1][0]
        chart[weekday - 1][1] = 1
        if weekday > 1 {
            for i in 0...weekday - 2 {
                if !NSDate.date(fromString: dates[i], format: DateFormat.Custom("YYYY-MM-DD"))!.isThisWeek(){
                    thisDay = thisSunday+i.day
                    dates[i] = thisDay.toString(format: DateFormat.Custom("YYYY-MM-DD"))
                    chart[i] = [0,1]
                }
                chart[i][1] = 1
            }
        }
        
        if weekday < 7 {
            for i in weekday...6 {
                if !NSDate.date(fromString: dates[i], format: DateFormat.Custom("YYYY-MM-DD"))!.isSameWeekOf(thisSunday-1.day){
                    thisDay = thisSunday+i.day
                    dates[i] = thisDay.toString(format: DateFormat.Custom("YYYY-MM-DD"))
                    chart[i] = [0,0]
                }
                chart[i][1] = 0
                thisWeekDays -= 1
            }
        }
        setDefaults ("main.chart",value: chart)
        setDefaults ("main.dates",value: dates)
        
        //初始化统计表数据
        let lastToday = getDefaults("main.today") as? NSDate ?? today
        if !lastToday!.isThisWeek() {
            if lastToday!.isSameWeekOf(NSDate.date(fromString: dates[6], format: DateFormat.Custom("YYYY-MM-DD"))!) == true {
                lastweek = thisweek
            }
            thisweek = [0,0]
        }
        if !lastToday!.isThisMonth() {
            month = 0
        }
        if !lastToday!.isThisYear() {
            year = 0
        }
        
        setDefaults("number.year",value: year)
        setDefaults("number.month", value: month)
        setDefaults("number.lastweek", value: lastweek)
        setDefaults("number.thisweek", value: thisweek)
        setDefaults("number.todays", value: todays)
        setDefaults ("main.today",value: today)
    }
    
    func plusOne() {
        chart[today.weekday-1][0] += 1
        setDefaults ("main.chart",value: chart)
        
        todays[0] += 1
        thisweek[0] += 1
        year += 1
        month += 1
        setDefaults("number.todays", value: todays)
        setDefaults("number.thisweek", value: thisweek)
        setDefaults("number.year",value: year)
        setDefaults("number.month", value: month)
        NSNotificationCenter.defaultCenter().postNotificationName("refresh", object: nil)
    }
    
    func plusOneNotFinish() {
        if pomodoroClass.pomoMode == 1 {
            todays[1] += 1
            thisweek[1] += 1
            setDefaults("number.todays", value: todays)
            setDefaults("number.thisweek", value: thisweek)
        }

    }
    
    func getToday(timer:NSTimer) {
        if NSDate.today() != today {
            today = NSDate.today()
            updateData()
        }
    }
    
    //NSUserDefaults
    private let defaults = NSUserDefaults.standardUserDefaults()
    private func getDefaults (key: String) -> AnyObject? {
        if key != "" {
            return defaults.objectForKey(key)
        } else {
            return nil
        }
    }
    
    private func setDefaults (key: String,value: AnyObject) {
        if key != "" {
            defaults.setObject(value,forKey: key)
        }
    }
}
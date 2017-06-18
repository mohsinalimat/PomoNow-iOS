//
//  StatisticsTableViewController.swift
//  PomoNow
//
//  Created by Megabits on 16/1/15.
//  Copyright © 2016年 ScrewBox. All rights reserved.
//

import UIKit

class StatisticsTableViewController: UITableViewController {

    
    @IBOutlet var todayNumber: NumberWCView!
    @IBOutlet var lastWeekNumber: NumberWCView!
    @IBOutlet var thisWeekNumber: NumberWCView!
    @IBOutlet var monthNumber: NumberWCView!
    @IBOutlet var yearNumber: NumberWCView!
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(StatisticsTableViewController.refresh(_:)), name: "refresh", object: nil)
    }
    
    func refresh(title:NSNotification){
        updateUI()
    }
    
    func updateUI(){
        todayNumber.theNumber = cManager.todays[0]
        todayNumber.theNumber2 = cManager.todays[1]
        thisWeekNumber.theNumber = cManager.thisweek[0]
        thisWeekNumber.theNumber2 = cManager.thisweek[1]
        lastWeekNumber.theNumber = cManager.lastweek[0]
        lastWeekNumber.theNumber2 = cManager.lastweek[1]
        yearNumber.theNumber = cManager.year
        monthNumber.theNumber = cManager.month
    }
}

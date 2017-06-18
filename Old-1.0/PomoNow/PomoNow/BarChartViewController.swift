//
//  BarChartViewController.swift
//  PomoNow
//
//  Created by Megabits on 16/1/12.
//  Copyright © 2016年 ScrewBox. All rights reserved.
//

import UIKit

class BarChartViewController: UIViewController {

    @IBOutlet var barChart: BarChartView!
    var week = [NSLocalizedString("Sun", comment: "Sun"),NSLocalizedString("Mon", comment: "Mon"),NSLocalizedString("Tue", comment: "Tue"),NSLocalizedString("Wed", comment: "Wed"),NSLocalizedString("Thu", comment: "Thu"),NSLocalizedString("Fri", comment: "Fri"),NSLocalizedString("Sat", comment: "Sat")]
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(BarChartViewController.refresh(_:)), name: "refresh", object: nil)
    }
    
    func refresh(title:NSNotification){
        updateUI()
    }
    func updateUI(){
        barChart.clear()
        for i in 0...6 {
            var enable = true
            if cManager.chart[i][1] == 0 {
                enable = false
            }
            _ = barChart.addData(week[i],data: Double(cManager.chart[i][0]),enable: enable)
        }
    }
}

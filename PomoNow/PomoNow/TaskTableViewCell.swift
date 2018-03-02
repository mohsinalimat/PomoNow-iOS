//
//  TaskTableViewCell.swift
//  PomoNow
//
//  Created by Megabits on 15/10/17.
//  Copyright © 2015年 Jinyu Meng. All rights reserved.
//

import UIKit

class TaskTableViewCell: UITableViewCell {
    
    @IBOutlet weak var taskLabel: UILabel!
    @IBOutlet weak var colorTag: UIView!
    @IBOutlet weak var times: UILabel!
    
    var tagColor = 0 {
        didSet {
            switch tagColor {
            case 0:colorTag.backgroundColor = colorRed
            case 1:colorTag.backgroundColor = colorYellow
            case 2:colorTag.backgroundColor = colorBlue
            case 3:colorTag.backgroundColor = colorPink
            case 4:colorTag.backgroundColor = colorGray
            default:break
            }
        }
    }
}

//
//  NumberWCView.swift
//  Test
//
//  Created by Megabits on 16/1/14.
//  Copyright © 2016年 JinyuMeng. All rights reserved.
//

import UIKit

@IBDesignable class NumberWCView: UIView {
    
    @IBInspectable var theNumber:Int = 0
    @IBInspectable var theNumber2:Int = 0
    @IBInspectable var barColor:UIColor = UIColor(red: 255/255, green: 121/255, blue: 100/255, alpha: 1)
    @IBInspectable var barColor2:UIColor = UIColor(red: 255/255, green: 121/255, blue: 100/255, alpha: 1)
    override func drawRect(rect: CGRect) {
        var nowWidth:CGFloat = 30
        
        let label = UILabel(frame:CGRect(origin: CGPointMake(0,0), size: CGSizeMake(0, 0)))
        label.textColor = UIColor.whiteColor()
        label.text = "\(theNumber)"
        label.textAlignment = NSTextAlignment.Center
        label.font = UIFont.systemFontOfSize(15)
        
        var text:String = label.text!
        var attributes = [NSFontAttributeName: label.font!]
        label.frame = labelSize(text, attributes: attributes)
        label.center = self.center
        if label.frame.width > 20 {
            nowWidth = label.frame.width + 10
        }
        
        var rectPoint = CGPointMake(self.frame.width - nowWidth, 0)
        var rectSize = CGSizeMake(nowWidth, self.frame.height)
        barColor.setFill()
        var pathRect = CGRectInset(CGRect(origin: rectPoint,size: rectSize), 1, 1)
        let path = UIBezierPath(roundedRect: pathRect, cornerRadius: 3)
        path.fill()
        
        label.frame.origin = CGPointMake(path.bounds.origin.x + path.bounds.width/2 - label.frame.width/2, 0)
        self.addSubview(label)
        
        
        var nowWidth2:CGFloat = 30
        
        let label2 = UILabel(frame:CGRect(origin: CGPointMake(0,0), size: CGSizeMake(0, 0)))
        label2.textColor = UIColor.whiteColor()
        label2.text = "\(theNumber2)"
        label2.textAlignment = NSTextAlignment.Center
        label2.font = UIFont.systemFontOfSize(15)
        
        text = label2.text!
        attributes = [NSFontAttributeName: label2.font!]
        label2.frame = labelSize(text, attributes: attributes)
        label2.center = self.center
        if label2.frame.width > 20 {
            nowWidth2 = label2.frame.width + 10
        }
        
        rectPoint = CGPointMake(self.frame.width - nowWidth2 - nowWidth - 2, 0)
        rectSize = CGSizeMake(nowWidth2, self.frame.height)
        barColor2.setFill()
        pathRect = CGRectInset(CGRect(origin: rectPoint,size: rectSize), 1, 1)
        let path2 = UIBezierPath(roundedRect: pathRect, cornerRadius: 3)
        path2.fill()
        
        label2.frame.origin = CGPointMake(path2.bounds.origin.x + path2.bounds.width/2 - label2.frame.width/2 , 0)
        self.addSubview(label2)
        
    }
    func labelSize(text:String ,attributes : [String : AnyObject]) -> CGRect{
        var size = CGRect();
        let size2 = CGSize(width: 200, height: 0);
        size = text.boundingRectWithSize(size2, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: attributes , context: nil);
        return size
    }
}

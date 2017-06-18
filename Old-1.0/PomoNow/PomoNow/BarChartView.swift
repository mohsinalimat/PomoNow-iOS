//
//  BarChartView.swift
//  BarChartView
//
//  Created by Megabits on 15/11/16.
//  Copyright © 2015年 JinyuMeng. All rights reserved.
//

import UIKit

@IBDesignable class BarChartView: UIView {
    
    private var BarChartData = [(label:String, data:Double, enable:Bool)]()
    private var oneHeight:Double = 25
    @IBInspectable var barColor:UIColor = UIColor(red: 255/255, green: 121/255, blue: 100/255, alpha: 1)
    @IBInspectable var barDisableColor:UIColor = UIColor(red: 255/255, green: 200/255, blue: 200/255, alpha: 1)
    @IBInspectable var lineColor:UIColor = UIColor(red: 100/255, green: 100/255, blue: 100/255, alpha: 1)
    @IBInspectable var barWidth:Double = 27
    
    override func drawRect(rect: CGRect) {
        let frameWidth = frame.width
        let frameHeight = frame.height
        var labels = [UILabel]()
        var bars = [UIBezierPath]()
        var barLabels = [UILabel]()
        var labelOfBar = ""
        self.subviews.forEach({ $0.removeFromSuperview() })
        
        //Draw Bars
        let allBarWidth = Double(BarChartData.count) * barWidth
        let blankWidth = (Double(frameWidth) - 20 - allBarWidth) / Double(BarChartData.count + 1)
        var maxValue:Double = 2
        var valueHeight:Double = 0
        var aHeight:Double = 0
        if blankWidth > 0 && BarChartData.count > 0{
            for item in BarChartData {
                if item.data > maxValue {
                    maxValue = item.data
                }
            }
            aHeight = (Double(frameHeight) - 30 - oneHeight) / (maxValue) //单位数字对应的统计图长度
            let bHeight = oneHeight
            if aHeight > bHeight {
                oneHeight = 0
                valueHeight = (Double(frameHeight) - 30 - oneHeight) / (maxValue)
            } else {
                valueHeight = (Double(frameHeight) - 30 - oneHeight) / (maxValue - 1)
            }
            for i in 0...BarChartData.count - 1 {
                bars.append(UIBezierPath())
                var aPoint = 10 + Double(i + 1) * blankWidth + Double(i) * barWidth
                bars[i].moveToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30)))
                aPoint = 10 + Double(i + 1) * blankWidth + Double(i + 1) * barWidth
                bars[i].addLineToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30)))
                if BarChartData[i].data > 0 {//在长度不足显示数字标签的时候，提高数字为1的统计图高度
                    if aHeight > bHeight {
                        aPoint = 10 + Double(i + 1) * blankWidth + Double(i + 1) * barWidth
                        bars[i].addLineToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30) - oneHeight - (BarChartData[i].data) * valueHeight))
                        aPoint = 10 + Double(i + 1) * blankWidth + Double(i) * barWidth
                        bars[i].addLineToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30) - oneHeight - (BarChartData[i].data) * valueHeight))
                    } else {
                        aPoint = 10 + Double(i + 1) * blankWidth + Double(i + 1) * barWidth
                        bars[i].addLineToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30) - oneHeight - (BarChartData[i].data - 1) * valueHeight))
                        aPoint = 10 + Double(i + 1) * blankWidth + Double(i) * barWidth
                        bars[i].addLineToPoint(CGPoint(x:aPoint,y:Double(frameHeight - 30) - oneHeight - (BarChartData[i].data - 1) * valueHeight))
                    }
                    
                    if BarChartData[i].enable {
                        barColor.setFill()
                    } else {
                        barDisableColor.setFill()
                    }
                    bars[i].fill()
                    labelOfBar = "\(Int(BarChartData[i].data))"
                }
                //Draw bar Labels
                let lX = 10 + Double(i + 1) * blankWidth + Double(i) * barWidth
                var lY:Double = 0
                if aHeight > bHeight {
                    lY = Double(frameHeight - 30) - oneHeight - (BarChartData[i].data) * valueHeight - 7
                } else {
                    lY = Double(frameHeight - 30) - oneHeight - (BarChartData[i].data - 1) * valueHeight - 7
                }
                labels.append(UILabel(frame: CGRect(x:lX, y:lY, width:barWidth, height: 40)))
                labels[i].textAlignment = NSTextAlignment.Center
                labels[i].text = labelOfBar
                labels[i].textColor = UIColor.whiteColor()
                addSubview(labels[i])
                let bLWidth = barWidth + blankWidth
                let bLLeft = (Double(frameWidth) - bLWidth * Double(BarChartData.count))/2
                barLabels.append(UILabel(frame: CGRect(x:bLLeft + Double(i) * bLWidth, y:Double(frameHeight - 30), width:bLWidth, height: 40)))
                barLabels[i].textAlignment = NSTextAlignment.Center
                barLabels[i].textColor = UIColor.blackColor()
                if Int(BarChartData[i].label) > 99 {
                    BarChartData[i].label = "99"
                }
                barLabels[i].text = BarChartData[i].label
                addSubview(barLabels[i])
                
            }
        }
        
        let lineThickness: CGFloat = 1.5
        let linePath = UIBezierPath()
        linePath.lineWidth = lineThickness
        linePath.moveToPoint(CGPoint(x:0,y:frameHeight - 30))
        linePath.addLineToPoint(CGPoint(x:frameWidth,y:frameHeight - 30))
        lineColor.setStroke()
        linePath.stroke()
    }
    
    func addData(label:String, data:Double, enable:Bool) -> Int?{
        BarChartData.append((label:label, data:data, enable:enable))
        setNeedsDisplay()
        return BarChartData.count - 1
    }
    
    func getData(index:Int) -> (label:String, data:Double, enable:Bool)?{
        if index > BarChartData.count {
            return (label:BarChartData[index].label, data:BarChartData[index].data, enable:BarChartData[index].enable)
        } else {
            return nil
        }
    }
    
    func setData(index:Int, label:String? = nil, data:Double? = nil, enable:Bool? = nil){
        if index < BarChartData.count {
            if label != nil {
                BarChartData[index].label = label!
            }
            if data != nil {
                BarChartData[index].data = data!
            }
            if enable != nil {
                BarChartData[index].enable = enable!
            }
        }
        setNeedsDisplay()
    }
    
    func clear() {
        BarChartData = [(label:String, data:Double, enable:Bool)]()
        setNeedsDisplay()
    }
}
//
//  File.swift
//  ViewTest
//
//  Created by 孟金羽 on 16/8/14.
//  Copyright © 2016年 Jinyu Meng. All rights reserved.
//

import UIKit

@IBDesignable class StatisticsView: UIView {
    
    @IBInspectable var withGraph:Bool = false
    @IBInspectable var enable:Bool = true
    @IBInspectable var title:String = "Title"
    @IBInspectable var subTitle:String = "-/-"
    @IBInspectable var indicatorMax:CGFloat = 100
    @IBInspectable var indicator:CGFloat = 50
    @IBInspectable var textColor:UIColor = UIColor.black
    @IBInspectable var indicatorBackGroundColor:UIColor = UIColor.gray
    @IBInspectable var indicatorTintColor:UIColor = UIColor.red
    @IBInspectable var graphLineColor:UIColor = UIColor.gray
    @IBInspectable var graphChartColor:UIColor = UIColor.gray
    var titleLabel = UILabel(frame:CGRect(x: 0, y: 10, width: 100, height: 30))
    var subTitleLabel = UILabel(frame:CGRect(x: 0, y: 10, width: 100, height: 30))
    var notAvailableLabel = UILabel(frame: CGRect(x: 0, y: 140, width: 100, height: 20))
    let topNumberLabel = UILabel(frame: CGRect(x: 0, y: 90, width: 100, height: 20))
    let bottomNumberLabel = UILabel(frame: CGRect(x: 0, y: 190, width: 100, height: 20))
    var chartArray = [Int]()
    
    //总高度220 无统计图高度80
    
    override func draw(_ rect: CGRect) {
        //顶部文本
        titleLabel = UILabel(frame:CGRect(x: 0, y: 10, width: frame.width / 2, height: 30))
        titleLabel.text = title
        titleLabel.textColor = textColor
        titleLabel.font = UIFont.systemFont(ofSize: 24)
        titleLabel.textAlignment=NSTextAlignment.left
        addSubview(titleLabel)
        subTitleLabel = UILabel(frame:CGRect(x: self.frame.width / 2, y: 10, width: self.frame.width / 2, height: 30))
        subTitleLabel.text = subTitle
        subTitleLabel.textColor = textColor
        subTitleLabel.font = UIFont.systemFont(ofSize: 24)
        subTitleLabel.textAlignment=NSTextAlignment.right
        addSubview(subTitleLabel)
        //进度条
        var rect = CGRect(x: 0, y: 50, width: frame.width, height: 20)
        let indicatorBackGround = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        indicatorBackGroundColor.setFill()
        indicatorBackGround.fill()
        
        let percent:CGFloat = indicator / indicatorMax
        var indicatorLong = frame.width * percent
        if indicatorLong < 20 && indicator != 0{
            indicatorLong = 20
        }
        if !enable {
            indicatorLong = 0
        }
        
        rect = CGRect(x: 0, y: 50, width: indicatorLong, height: 20)
        let indicatorFrontGround = UIBezierPath(roundedRect: rect, cornerRadius: 10)
        indicatorTintColor.setFill()
        indicatorFrontGround.fill()
        let lineThickness: CGFloat = 1
        
        if withGraph {
            var maxValue = 0
            if chartArray == [] {
                maxValue = 100
            } else {
                maxValue = Int(chartArray.max()!)
            }
            
            if enable{
                let linePathMiddle = UIBezierPath()
                linePathMiddle.lineWidth = lineThickness
                linePathMiddle.move(to: CGPoint(x:0,y:150))
                linePathMiddle.addLine(to: CGPoint(x:frame.width,y:150))
                graphLineColor.setStroke()
                linePathMiddle.stroke()
            } else {
                notAvailableLabel = UILabel(frame: CGRect(x: 0, y: 140, width: frame.width, height: 20))
                notAvailableLabel.text = NSLocalizedString("Not Available",comment:"Not Available")
                notAvailableLabel.textColor = graphLineColor
                notAvailableLabel.font = UIFont.systemFont(ofSize: 14)
                notAvailableLabel.textAlignment=NSTextAlignment.center
                addSubview(notAvailableLabel)
            }
            
            if enable {
                //图表本体
                var chartWidth:CGFloat = 0
                if chartArray == [] {
                    chartWidth = 10
                } else {
                    chartWidth = (frame.width - 45) / CGFloat(chartArray.count * 2)
                }
                
                if chartArray != [] {
                    var pencil:Double = 35
                    for strip in chartArray {
                        var localVaue = maxValue
                        if localVaue == 0 {
                            localVaue = 1
                        }
                        let chartLong = Double(strip) / Double(localVaue) * 120
                        rect = CGRect(x: pencil, y: Double(210 - chartLong), width: Double(chartWidth), height: chartLong)
                        let aChart = UIBezierPath(roundedRect: rect, cornerRadius: 0)
                        graphChartColor.setFill()
                        aChart.fill()
                        pencil += Double(chartWidth) * 2
                    }
                }
            }
                
            //图表框架
            let linePath = UIBezierPath()
            linePath.lineWidth = lineThickness
            linePath.move(to: CGPoint(x:0,y:90))
            linePath.addLine(to: CGPoint(x:frame.width,y:90))
            graphLineColor.setStroke()
            linePath.stroke()
            topNumberLabel.text = "\(maxValue)"
            topNumberLabel.textColor = graphLineColor
            topNumberLabel.font = UIFont.systemFont(ofSize: 14)
            addSubview(topNumberLabel)
                
            let linePathBottom = UIBezierPath()
            linePathBottom.lineWidth = lineThickness
            linePathBottom.move(to: CGPoint(x:0,y:210))
            linePathBottom.addLine(to: CGPoint(x:frame.width,y:210))
            graphLineColor.setStroke()
            linePathBottom.stroke()
            bottomNumberLabel.text = "0"
            bottomNumberLabel.textColor = graphLineColor
            bottomNumberLabel.font = UIFont.systemFont(ofSize: 14)
            addSubview(bottomNumberLabel)
        }
        //无障碍设定
        self.isAccessibilityElement = true
        if enable {
            let finishedAccessibilityLabel = NSLocalizedString("Finished", comment: "Finished") + "\(Int(indicator))"
            let allAccessibilityLabel = NSLocalizedString("All", comment: "All") + "\(Int(indicatorMax))"
            var chartAccessibilityLabel = ""
            if withGraph {
                if chartArray == [] {
                    chartAccessibilityLabel = NSLocalizedString("No details", comment: "No details")
                } else {
                    chartAccessibilityLabel = NSLocalizedString("Details", comment: "Details")
                    for item in chartArray {
                        chartAccessibilityLabel = chartAccessibilityLabel + "\(item)" + " "
                    }
                }
            }
            self.accessibilityLabel = title + finishedAccessibilityLabel + allAccessibilityLabel + chartAccessibilityLabel
        } else {
            self.accessibilityLabel = title + NSLocalizedString("No data", comment: "No data")
        }
    }
    
    func reload() {
        subTitleLabel.removeFromSuperview()
        titleLabel.removeFromSuperview()
        notAvailableLabel.removeFromSuperview()
        topNumberLabel.removeFromSuperview()
        bottomNumberLabel.removeFromSuperview()
        setNeedsDisplay()
    }
}

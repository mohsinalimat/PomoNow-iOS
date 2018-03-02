//
//  CProgressView.swift
//  CProgressView
//
//  Created by Megabits on 21.04.2015.
//  Copyright (c) 2015 Jinyu Meng. All rights reserved.
//

import UIKit

@IBDesignable class CProgressView: UIView {
    
    fileprivate var π: CGFloat = CGFloat(Double.pi)
    fileprivate var progressCircle = CAShapeLayer()
    fileprivate var realProgressCircle = CAShapeLayer()
    fileprivate var circlePath = UIBezierPath()
    internal var statusProgress: Int = Int()

    //计算角度
    fileprivate func arc(_ arc: CGFloat) -> CGFloat {
        let results = ( π * arc ) / 180
        return results
    }

    @IBInspectable var circleColor: UIColor = UIColor.gray
    @IBInspectable var progressColor: UIColor = UIColor.green
    @IBInspectable var lineWidth: Float = Float(3.0)
    @IBInspectable var valueProgress: Float = Float()
    
    override func draw(_ rect: CGRect) {

        // Create Path for ARC
        let centerPointArc = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radiusArc: CGFloat = self.frame.width / 2 * 0.8
        circlePath = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(-90), endAngle: arc(450), clockwise: true)

        // Define background circle progress
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = circleColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = CGFloat(lineWidth)
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 100

        // Define real circle progress
        realProgressCircle.path = circlePath.cgPath
        realProgressCircle.strokeColor = progressColor.cgColor
        realProgressCircle.fillColor = UIColor.clear.cgColor
        realProgressCircle.lineWidth = CGFloat(lineWidth) + 0.1
        realProgressCircle.strokeStart = 0
        realProgressCircle.strokeEnd = CGFloat(valueProgress) / 100
        if realProgressCircle.strokeEnd > 0.6666 {
            realProgressCircle.strokeEnd = 0.6666
        }
        
        // Set for sublayer circle progress
        layer.addSublayer(progressCircle)
        layer.addSublayer(realProgressCircle)
    }

}

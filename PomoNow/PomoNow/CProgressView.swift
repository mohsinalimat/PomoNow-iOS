//
//  CProgressView.swift
//  CProgressView
//
//  Created by Sebastian Trześniewski on 21.04.2015.
//  Copyright (c) 2015 Sebastian Trześniewski. All rights reserved.
//

import UIKit

@IBDesignable class CProgressView: UIView {
    
    // Variables
    private var π: CGFloat = CGFloat(M_PI)
    private var progressCircle = CAShapeLayer()
    private var realProgressCircle = CAShapeLayer()
    private var circlePath = UIBezierPath()
    internal var statusProgress: Int = Int()

    // Method for calculate ARC
    private func arc(_ arc: CGFloat) -> CGFloat {
        let results = ( π * arc ) / 180
        return results
    }
    
    // Variables for IBInspectable
    @IBInspectable var circleColor: UIColor = UIColor.gray
    @IBInspectable var progressColor: UIColor = UIColor.green
    @IBInspectable var lineWidth: Float = Float(3.0)
    @IBInspectable var valueProgress: Float = Float() {
        didSet{
            if valueProgress > 100 {
                valueProgress = 100
            } else if valueProgress < 0 {
                valueProgress = 0
            }
        }
    }
    
    override func draw(_ rect: CGRect) {

        // Create Path for ARC
        let centerPointArc = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        let radiusArc: CGFloat = frame.width / 2
        circlePath = UIBezierPath(arcCenter: centerPointArc, radius: radiusArc, startAngle: arc(-90), endAngle: arc(450), clockwise: true)

        // Define background circle progress
        progressCircle.path = circlePath.cgPath
        progressCircle.strokeColor = circleColor.cgColor
        progressCircle.fillColor = UIColor.clear.cgColor
        progressCircle.lineWidth = CGFloat(lineWidth)
        progressCircle.strokeStart = 0
        progressCircle.strokeEnd = 1

        // Define real circle progress
        realProgressCircle.path = circlePath.cgPath
        realProgressCircle.strokeColor = progressColor.cgColor
        realProgressCircle.fillColor = UIColor.clear.cgColor
        realProgressCircle.lineWidth = CGFloat(lineWidth)
        realProgressCircle.strokeStart = 0
        realProgressCircle.strokeEnd = CGFloat(valueProgress) / 150
        
        // Set for sublayer circle progress
        layer.addSublayer(progressCircle)
        layer.addSublayer(realProgressCircle)
    }

}

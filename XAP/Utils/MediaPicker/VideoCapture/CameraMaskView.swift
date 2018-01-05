//
//  VideoCaptureViewController.swift
//  XAP
//
//  Created by Alex on 16/5/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import UIKit

class CameraMaskView: UIView {
    
    /// Returns scan rect (ROI area in view)
    var scanRect:CGRect{
        return CGRect(center: roiCenter ?? center, size: roiSize)
    }
    
    /// ROI Size
    var roiSize:CGSize = CGSize(width: 200, height: 200){
        didSet{
            setNeedsDisplay()
        }
    }
    
    /// MASK Color (Default alpha 0.5)
    var maskColor:UIColor = UIColor(white: 0, alpha: 0.5){
        didSet{
            setNeedsDisplay()
        }
    }
    
    /// Edge radius (Default 15.0)
    var edgeRadius:CGFloat = 15.0 {
        didSet{
            setNeedsDisplay()
        }
    }
    
    var roiCenter:CGPoint? = nil{
        didSet{
            setNeedsDisplay()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = .clear
    }
    
    // Super Important.
    override func draw(_ rect: CGRect) {
        
        let bezierPath = UIBezierPath()
        let width = bounds.width
        let height = bounds.height
        
        let scanRect = self.scanRect
        bezierPath.move(to: CGPoint(x: scanRect.minX, y: scanRect.minY))
        bezierPath.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.maxY))
        bezierPath.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.maxY))
        bezierPath.addLine(to: CGPoint(x: scanRect.maxX, y: scanRect.minY))
        bezierPath.addLine(to: CGPoint(x: scanRect.minX, y: scanRect.minY))
        bezierPath.close()
        
        bezierPath.move(to: CGPoint(x: width, y: 0))
        bezierPath.addCurve(to: CGPoint(x: width, y: height), controlPoint1: CGPoint(x: width, y: 0), controlPoint2: CGPoint(x: width, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: height))
        bezierPath.addLine(to: CGPoint(x: 0, y: 0))
        bezierPath.addLine(to: CGPoint(x: width, y: 0))
        bezierPath.close()
        
        maskColor.setFill()
        bezierPath.fill()
        
        //Draw white rectangle
        let rectBezierPath = UIBezierPath(rect: scanRect)
        rectBezierPath.lineWidth = 1.0
        UIColor(white: 0.5, alpha: 1.0).setStroke()
        rectBezierPath.stroke()
        
        let r = scanRect.insetBy(dx: -2, dy: -2)
        
        //Draw corners
        let path = UIBezierPath()
        
        path.move(to: CGPoint(x: r.minX, y: r.minY + edgeRadius))
        path.addLine(to: CGPoint(x: r.minX, y: r.minY))
        path.addLine(to: CGPoint(x: r.minX + edgeRadius, y: r.minY))
        
        path.move(to: CGPoint(x: r.maxX - edgeRadius, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.minY + edgeRadius))
        
        path.move(to: CGPoint(x: r.maxX - edgeRadius, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.maxX, y: r.maxY - edgeRadius))
        
        path.move(to: CGPoint(x: r.minX + edgeRadius, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.maxY))
        path.addLine(to: CGPoint(x: r.minX, y: r.maxY - edgeRadius))
        
        path.lineWidth = 2.0
        UIColor.white.setStroke()
        path.stroke()
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
        super.layoutSubviews()
    }
}

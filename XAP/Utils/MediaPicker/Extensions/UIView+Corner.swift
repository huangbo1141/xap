//
//  UIView+Corner.swift
//  XAP
//
//  Created by Zhang Yi on 14/1/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    /**
     Make Oval Border
     - Parameter color : Border Color
     - Parameter borderWidth : Border Width
     */
    func makeOvalBorder(color:UIColor, borderWidth bw:CGFloat){
        // try get reasonable width
        var width:CGFloat?, height:CGFloat?
        for constraint in constraints{
            if constraint.firstAttribute == .width && constraint.relation == .equal && constraint.secondItem == nil && constraint.isActive{
                width = constraint.constant
            }
            if constraint.secondAttribute == .height && constraint.relation == .equal && constraint.secondItem == nil && constraint.isActive {
                height = constraint.constant
            }
        }
        
        if let width = width, let height = height {
            setupBorder(color: color, borderWidth: bw, cornerRadius: min(width, height) / 2.0)
        } else if let width = width {
            setupBorder(color: color, borderWidth: bw, cornerRadius: width / 2.0)
        } else if let height = height {
            setupBorder(color: color, borderWidth: bw, cornerRadius: height / 2.0)
        }
    }
    
    /**
     Set Corner Radius
     - Parameter color : Color of border, can be clear color
     - Parameter borderWidth : Width of border
     - Parameter cornerRadius : Corner radius of border
     */
    func setupBorder(color:UIColor, borderWidth bw:CGFloat, cornerRadius r:CGFloat){
        layer.masksToBounds = true
        layer.borderColor = color.cgColor
        layer.borderWidth = bw
        layer.cornerRadius = r
    }
}

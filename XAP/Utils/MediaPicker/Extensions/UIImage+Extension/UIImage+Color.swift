//
//  UIImage+Color.swift
//  XAP
//
//  Created by Zhang Yi on 16/12/2015.
//  Copyright © 2015 JustTwoDudes. All rights reserved.
//

import Foundation

extension UIImage{
    /// Returns Image with color
    static func colored(_ color:UIColor) -> UIImage{
        let rect = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
    
    /// Returns Image with oval image color
    class func oval(withColor color:UIColor, radius:CGSize) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: radius.width * 2, height: radius.height * 2)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: radius)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        path.lineWidth = 0.0
        context?.addPath(path.cgPath)
        context?.setFillColor(color.cgColor)
        context?.fillPath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

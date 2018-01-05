//
//  UIImage+Extensions.swift
//  JobinRecruiter
//
//  Created by Alex on 25/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import Foundation

extension UIImage {
    /// Returns Image with color
    class func image(color:UIColor) -> UIImage {
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
    class func ovalImageWithColor(_ color:UIColor, radius:CGSize) -> UIImage{
        let rect = CGRect(x: 0, y: 0, width: radius.width * 2, height: radius.height * 2)
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: [.allCorners], cornerRadii: radius)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        path.lineWidth = 0.0
        color.setFill()
        path.fill()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}

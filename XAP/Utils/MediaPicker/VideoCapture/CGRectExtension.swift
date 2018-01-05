//
//  VideoCaptureViewController.swift
//  XAP
//
//  Created by Alex on 16/5/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

// MARK: - Handful extensions
extension CGRect {
    /// Center point of the CGRect
    var center:CGPoint {
        return CGPoint(x: midX, y: midY)
    }
    
    /// Return rect as portrait if origin is landscape mode
    var portrait : CGRect {
        if self.size.width > self.size.height {
            let portraitRect = CGRect(origin: self.origin, size: CGSize(width: self.size.height, height: self.size.width))
            return portraitRect
        }
        return self
    }
    
    /// Centered Rect
    func centeredRect(size:CGSize) -> CGRect{
        return CGRect(center: center, size: size)
    }
    
    /// Get Origin of centered rect.
    func originFor(centered size:CGSize) -> CGPoint{
        return centeredRect(size: size).origin
    }
    
    init (center:CGPoint, size:CGSize){
        self.init(origin:CGPoint(x:center.x - size.width / 2, y:center.y - size.height / 2),
                  size:size
        )
    }
}

// The reason for extensing CGSize rather than CGRect is to be confident that source rect and destination rect origin is always CGPointZero.

// MARK: - Coordinate conversion when scaling
// If considered about performance, do not use these.
extension CGSize {
    
    /**
     Convert point to new size (scaling)
     - Parameter point : relative position in bounds with current size.
     - Parameter toSize : Scaled Size
     - Returns : point which is scaled to new bounds (relative position in new bounds with toSize)
     */
    func convert(point:CGPoint, toSize:CGSize) -> CGPoint{
        return CGPoint(
            x:point.x * toSize.width / width,
            y:point.y * toSize.height / height
        )
    }
    
    /**
     Convert point to new size (scaling)
     - Parameter size : size in bounds with current size.
     - Parameter toSize : Scaled Size
     - Returns : size which is scaled to new bounds
     */
    func convert(size:CGSize, toSize:CGSize) -> CGSize {
        return CGSize(
            width: size.width * toSize.width / width,
            height: size.height * toSize.height / height)
    }
    
    /**
     Convert rect to new size (scaling)
     - Parameter point : relative position in bounds with current size.
     - Parameter toSize : Scaled Size
     - Returns : point which is scaled to new bounds (relative position in new bounds with toSize)
     */
    func convert(rect:CGRect, toSize:CGSize) -> CGRect {
        return CGRect(
            origin: convert(point: rect.origin, toSize: toSize),
            size: convert(size: rect.size, toSize: toSize))
    }
}

// Size operator
public func <=(lhs:CGSize, rhs:CGSize) -> Bool{
    return lhs.width <= rhs.width && lhs.height <= rhs.height
}

public func <(lhs:CGSize, rhs:CGSize) -> Bool {
    return lhs.width < rhs.width && lhs.height < rhs.height
}

// CGSize scale operator
func *(lhs:CGSize, rhs:CGFloat) -> CGSize{
    return CGSize(width: lhs.width * rhs, height: lhs.height * rhs)
}

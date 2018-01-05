//
//  CMAcceleration+Orientation.swift
//  PickerTest
//
//  Created by Alex on 28/4/2016.
//  Copyright © 2016 StockNumSystems. All rights reserved.
//

import UIKit
import CoreMotion

// MARK: - UIInterfaceOrientation extension for obtaining control rotation
extension UIInterfaceOrientation{
    public var controlsRotationRadian:CGFloat {
        switch self {
        case .portrait:
            return 0
        case .landscapeRight:
            return CGFloat(M_PI * 90) / 180.0
        case .portraitUpsideDown:
            return CGFloat(M_PI * 180) / 180.0
        case .landscapeLeft:
            return CGFloat(M_PI * 270.0) / 180.0
        default:
            return 0
        }
    }
    
    public var controlsRotationTransform:CGAffineTransform{
        return CGAffineTransform.identity.rotated(by: controlsRotationRadian)
    }
}

// MARK: - CMAcceleration extension for interface orientation.
extension CMAcceleration {
    /**
     Converts acceleration data to interface orientation
     This ignores z value when its absolute value is bigger than 0.5
     To make it work similar to iOS does.
     */
    func toInterfaceOrientation() -> UIInterfaceOrientation? {
        guard abs(z) < 0.75 else {
            return nil
        }
        let angle = atan2(y, x)
        
        if angle >= -2.25 && angle <= -0.75 {
            return  .portrait
        } else if angle >= -0.75 && angle <= 0.75 {
            return .landscapeLeft
        } else if angle >= 0.75 && angle <= 2.25 {
            return  .portraitUpsideDown
        } else if (angle <= -2.25 || angle >= 2.25){
            return  .landscapeRight
        }
        return nil
    }
}

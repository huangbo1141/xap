//
//  UIView+Extension.swift
//  XAP
//
//  Created by Alex on 18/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    var capturedImage: UIImage {
        let renderer = UIGraphicsImageRenderer(size: self.bounds.size)
        let image = renderer.image { ctx in
            self.drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        }
        
        return image
    }
}

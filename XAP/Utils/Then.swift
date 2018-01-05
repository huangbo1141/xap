//
//  Then.swift
//  Trax
//
//  Created by Swift Coder on 10/20/16.
//  Copyright © 2016 Levi. All rights reserved.
//

import Foundation

public protocol Then {}

extension Then where Self: AnyObject {
    
/// Makes it available to set properties with closures just after initializing.
///
///     let label = UILabel().then {
///         $0.textAlignment = .Center
///         $0.textColor = UIColor.blackColor()
///         $0.text = "Hello, World!"
///     }
    @discardableResult
    public func then(_ block : (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

extension NSObject: Then {}

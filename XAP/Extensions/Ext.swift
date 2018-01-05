//
//  Ext.swift
//  XAP
//
//  Created by Alex on 17/10/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

public struct Ext<Base> {
    public let base:Base
    public init(_ base:Base){
        self.base = base
    }
}

public protocol ExtCompatible{
    associatedtype ExtCompatibleType
    static var ext:Ext<ExtCompatibleType>.Type { get }
    var ext:Ext<ExtCompatibleType> { get }
}

public extension ExtCompatible {
    /**
     Ext extensions.
     */
    public static var ext: Ext<Self>.Type {
        return Ext<Self>.self
    }
    
    /**
     Ext extensions.
     */
    public var ext: Ext<Self> {
        return Ext(self)
    }
}

extension NSObject: ExtCompatible {}

extension Ext {
    static var windowSize:CGSize {
        return UIApplication.shared.keyWindow!.bounds.size
    }
    
    static var windowFrame:CGRect{
        return UIApplication.shared.keyWindow!.bounds
    }
    
    var windowSize:CGSize {
        return UIApplication.shared.keyWindow!.bounds.size
    }
    
    var windowFrame:CGRect{
        return UIApplication.shared.keyWindow!.bounds
    }
}

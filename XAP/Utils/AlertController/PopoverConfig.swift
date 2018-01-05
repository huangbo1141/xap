//
//  PopoverConfig.swift
//  Cattivo VIA
//
//  Created by Alex on 14/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation

/**
 A configuration for `UIPopoverPresentationController`.
 */
public struct PopoverConfig {
    
    /**
     Describes the source view from which the popover is showing.
     */
    public enum Source {
        /// Specifies that the popover should display from a `UIBarButtonItem` instance.
        case barButtonItem(UIBarButtonItem)
        
        /// Specifies that the popover should display from a `UIView` instance.
        case view(UIView)
    }
    
    /// The source view for the popover.
    let source: Source
    
    /// The arrow direction of the popover.
    let arrowDirection: UIPopoverArrowDirection
    
    /// The delegate object for the popover presentation controller, or `nil`.
    let delegate: UIPopoverPresentationControllerDelegate?
    
    let sourceRect:CGRect?
    
    /**
     Initializes and returns a new `PopoverConfig` object.
     
     - parameter source:         The source for the popoever.
     - parameter arrowDirection: The arrow direction for the popover.
     - parameter delegate:       The delegate for the popover.
     
     - returns: A new `PopoverConfig` object.
     */
    public init(source: Source,
                arrowDirection: UIPopoverArrowDirection = [.any],
                delegate: UIPopoverPresentationControllerDelegate? = nil,
                sourceRect:CGRect? = nil) {
        self.source = source
        self.arrowDirection = arrowDirection
        self.delegate = delegate
        self.sourceRect = nil
    }
}

extension PopoverConfig {
    /**
     Config view controller to be presented as popover
     */
    func config(viewController vc:UIViewController){
        vc.popoverPresentationController?.then{
            switch source {
            case let .barButtonItem(barbuttonItem):
                $0.barButtonItem = barbuttonItem
            case let .view(view):
                $0.sourceView = view
            }
            if let sourceRect = self.sourceRect {
                $0.sourceRect = sourceRect
            }
            $0.permittedArrowDirections = arrowDirection
            $0.delegate = delegate
        }
    }
}

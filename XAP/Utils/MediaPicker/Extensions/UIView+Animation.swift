//
//  UIView+Animation.swift
//  XAP
//
//  Created by Alex on 25/3/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import UIKit

typealias DefaultBlock = () -> ()

fileprivate let kDefaultFadeDuration = 0.7

// MARK: - FadeIn, FadeOut
extension UIView {
    /**
     Fades Out view within duration
     - Parameter preAnimationBlock : Block to be called before call UIView.animateWithDuration...
     - Parameter completion : Completion Block
    */
    func fadeOut(duration:TimeInterval = kDefaultFadeDuration, preAnimationBlock:DefaultBlock? = nil, completion:((Bool) -> ())? = nil){
        preAnimationBlock?()
        UIView.animate(withDuration: duration,
                                   animations: {
                                    self.alpha = 0.0
        }){ completed in
            // Make alhpa zero and completely hide.
            if completed {
                self.isHidden = true
            }
            completion?(completed)
        }
    }
    
    /**
     Fades In View within duration
     - Parameter preAnimationBlock : Block to be called before call UIView.animateWithDuration...
     - Parameter completion : Completion Block
    */
    
    func fadeIn(duration:TimeInterval = kDefaultFadeDuration, preAnimationBlock:DefaultBlock? = nil, completion:((Bool) -> ())? =
        nil){
        // Unhide first.
        isHidden = false
        preAnimationBlock?()
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1.0
        }){ completed in
            if completed {
                self.isHidden = false
            }
            completion?(completed)
        }
    }
}

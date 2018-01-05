//
//  TextFieldEffects.swift
//  Cattivo VIA
//
//  Created by Alex on 12/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation

import UIKit

extension String {
    /**
     true iff self contains characters.
     */
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

/**
 A TextFieldEffects object is a control that displays editable text and contains the boilerplates to setup unique animations for text entrey and display. You typically use this class the same way you use UITextField.
 */
public class TextFieldEffects : UITextField {
    
    /**
     UILabel that holds all the placeholder information
     */
    public let placeholderLabel = UILabel()
    
    /**
     Creates all the animations that are used to leave the textfield in the "entering text" state.
     */
    public func animateViewsForTextEntry() {
        fatalError("\(#function) must be overridden")
    }
    
    /**
     Creates all the animations that are used to leave the textfield in the "display input text" state.
     */
    public func animateViewsForTextDisplay() {
        fatalError("\(#function) must be overridden")
    }
    
    /**
     Draws the receiver’s image within the passed-in rectangle.
     
     - parameter rect:	The portion of the view’s bounds that needs to be updated.
     */
    public func drawViewsForRect(_ rect: CGRect) {
        fatalError("\(#function) must be overridden")
    }
    
    public func updateViewsForBoundsChange(_ bounds: CGRect) {
        fatalError("\(#function) must be overridden")
    }
    
    // MARK: - Overrides
    
    override public func draw(_ rect: CGRect) {
        drawViewsForRect(rect)
    }
    
    override public func drawPlaceholder(in rect: CGRect) {
        // Don't draw any placeholders
    }
    
    override public var text: String? {
        didSet {
            if let text = text , text.isNotEmpty {
                animateViewsForTextEntry()
            } else {
                animateViewsForTextDisplay()
            }
        }
    }
    
    // MARK: - UITextField Observing
    
    override public func willMove(toSuperview newSuperview: UIView!) {
        if newSuperview != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidEndEditingNotification(_:)), name:.UITextFieldTextDidEndEditing, object: self)
            
            NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidBeginEditingNotification(_:)), name:.UITextFieldTextDidBeginEditing, object: self)
        } else {
            NotificationCenter.default.removeObserver(self)
        }
    }
    
    /**
     The textfield has started an editing session.
     */
    public func textFieldDidBeginEditingNotification(_ notification:Notification) {
        animateViewsForTextEntry()
    }
    
    /**
     The textfield has ended an editing session.
     */
    public func textFieldDidEndEditingNotification(_ notification:Notification) {
        animateViewsForTextDisplay()
    }
    
    // MARK: - Interface Builder
    
    override public func prepareForInterfaceBuilder() {
        drawViewsForRect(frame)
    }
}

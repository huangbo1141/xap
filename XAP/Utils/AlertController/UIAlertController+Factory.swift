//
//  UIAlertController+Factory.swift
//  Cattivo VIA
//
//  Created by Alex on 14/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

typealias AlertControllerResult = (style:UIAlertActionStyle, buttonIndex:Int)

// MARK: - Alert
extension UIAlertController {
    /**
     Creates an UIAlertController instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     - Parameter title : Title (Default nil)
     - Parameter message : Message (Default nil)
     - Parameter cancelTitle : Cancel Button(Default nil)
     - Parameter destructiveTitle : Destructive Title
     - Parameter otherTitles: Other titles
     - Parameter callback : AlertController Callback
     - Returns Configured AlertController
     */
    class func alert(title:String? = nil, message:String, cancelTitle ct:String? = nil, destructiveTitle dt:String? = nil, otherTitles:[String] = [], callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if let dt = dt {
            let destructiveAction =  UIAlertAction(title: dt, style: .destructive){ _ in
                callback?((.destructive, 0))
            }
            alert.addAction(destructiveAction)
        }
        
        for (index, title) in otherTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default){ _ in
                callback?((.default, index))
            }
            alert.addAction(action)
        }
        
        if let ct = ct {
            let cancelAction = UIAlertAction(title: ct, style: .cancel){ _ in
                callback?((.cancel, 0))
            }
            alert.addAction(cancelAction)
        }
        return alert
    }
}

// MARK: - ActionSheet
extension UIAlertController{
    /**
     Creates an UIAlertController ActionSheet instance with options and call back configured in parameter, Can use UIViewController's showAlerController: function to present it.
     - Parameter title : Title (Default nil)
     - Parameter message : Message (Default nil)
     - Parameter cancelTitle : Cancel Button(Default nil)
     - Parameter destructiveTitle : Destructive Title
     - Parameter otherTitles: Other titles
     - Parameter callback : AlertController Callback
     - Parameter popoverConfig : Popover Config
     - Returns Configured AlertController
     */
    class func actionSheet(title:String? = nil, cancelTitle ct:String? = nil, destructiveTitle dt:String? = nil, otherTitles:[String] = [],
                           popoverConfig:PopoverConfig, callback:((AlertControllerResult) -> Void)? = nil) -> UIAlertController {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
        
        
        if let dt = dt {
            let destructiveAction =  UIAlertAction(title: dt, style: .destructive){ _ in
                callback?((.destructive, 0))
            }
            alert.addAction(destructiveAction)
        }
        
        for (index, title) in otherTitles.enumerated() {
            let action = UIAlertAction(title: title, style: .default){ _ in
                callback?((.default, index))
            }
            alert.addAction(action)
        }
        
        if let ct = ct {
            let cancelAction = UIAlertAction(title: ct.description, style: .cancel){ _ in
                callback?((.cancel, 0))
            }
            alert.addAction(cancelAction)
        }
        
        popoverConfig.config(viewController: alert)
        return alert
    }
}

// MARK: - Input title
extension UIAlertController {
    class func textInput(title:String? = nil, message:String? = nil, configurator:((UITextField) -> Void)? = nil, okTitle:String = "OK", cancelTitle:String = "Cancel", validation:@escaping (String) -> Bool = {!$0.trimmingCharacters(in: .whitespaces).isEmpty}, callback:@escaping (String?) -> Void) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var subscription:Disposable?
        
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: {[weak alert] _ in
            subscription?.dispose()
            callback(alert?.textFields?.first?.text)
        })
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: {_ in
            subscription?.dispose()
            callback(nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        alert.addTextField { textField in
            configurator?(textField)
            subscription = textField.rx.text.map({ string -> Bool in
                return validation(string!)
            }).bindTo(okAction.rx.isEnabled)
        }
        return alert
    }
    
    class func multiTextInput(title:String? = nil, message:String? = nil, count: Int,configurator:((UITextField, Int) -> Void)? = nil, okTitle:String = "OK", cancelTitle:String = "Cancel", validation:@escaping (String) -> Bool = {!$0.trimmingCharacters(in: .whitespaces).isEmpty}, callback:@escaping ([String]?) -> Void) -> UIAlertController{
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        var subscription:Disposable?
        
        let okAction = UIAlertAction(title: okTitle, style: .default, handler: {[weak alert] _ in
            subscription?.dispose()
            callback(alert?.textFields.flatMap{ $0.map{ $0.text ?? "" } })
        })
        
        let cancelAction = UIAlertAction(title: cancelTitle, style: .cancel, handler: {_ in
            subscription?.dispose()
            callback(nil)
        })
        
        alert.addAction(cancelAction)
        alert.addAction(okAction)
        
        for index in 0..<count {
            alert.addTextField { textField in
                configurator?(textField, index)
                subscription = textField.rx.text.map({ string -> Bool in
                    return validation(string!)
                }).bindTo(okAction.rx.isEnabled)
            }
        }
        
        return alert
    }
}

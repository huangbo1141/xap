//
//  UIViewController+Extensions.swift
//  JobinRecruiter
//
//  Created by Alex on 30/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import Foundation

extension UIViewController {
    func popViewController() -> UIViewController? {
        return navigationController?.popViewController(animated: true)
    }
    
    func topMostController() -> UIViewController? {
        let topController = UIApplication.shared.keyWindow?.rootViewController
        guard var _topController = topController else { return nil }
        while _topController.presentedViewController != nil {
            _topController = _topController.presentedViewController!;
        }
        return _topController
    }
}

//
//  ActivityHUDPresenter.swift
//  Cattivo VIA
//
//  Created by Alex on 13/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import UIKit

protocol ActivityHUDPresenter {
    var hudContainerView:UIView { get }
}

extension ActivityHUDPresenter where Self:UIViewController {
    var hudContainerView:UIView {
        return view
    }
}

extension ActivityHUDPresenter where Self:UIView {
    var hudContainerView:UIView {
        return self
    }
}

extension ActivityHUDPresenter{
    // Private function for activity HUD.
    private func _showActivityHUD(message:String?, detailedMessage:String?, contentView:UIView?, topMost:Bool) -> MBProgressHUD{
        let view = topMost ? UIApplication.shared.keyWindow! : hudContainerView
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.message = message
        hud.detailedMessage = detailedMessage
        if let contentView = contentView {
            hud.contentView = contentView
            hud.mode = .customView
        }
        hud.show(animated: true)
        return hud
    }
    
    /**
     shows activity indicator (MBProgressHUD)
     */
    func showActivityHUD(message:String? = nil, detailedMessage:String? = nil, contentView:UIView? = nil) -> MBProgressHUD{
        return _showActivityHUD(message: message, detailedMessage: detailedMessage, contentView: contentView, topMost: false)
    }
    
    /**
     shows top most activity indicator
     */
    func showActivityHUDTopMost(message:String? = nil, detailedMessage:String? = nil, contentView:UIView? = nil) -> MBProgressHUD{
        return _showActivityHUD(message: message, detailedMessage: detailedMessage, contentView: contentView, topMost: true)
    }
}

extension UIView: ActivityHUDPresenter {}
extension UIViewController: ActivityHUDPresenter {}

extension MBProgressHUD {
    var message:String?{
        set {
            label.text = newValue
        }
        get {
            return label.text
        }
    }
    
    var detailedMessage:String? {
        set {
            detailsLabel.text = newValue
        }
        get {
            return detailsLabel.text
        }
    }
    
    var contentView:UIView?{
        set {
            guard let newValue = newValue else { return }
            mode = .customView
            customView = newValue
        }
        get {
            return customView
        }
    }
}

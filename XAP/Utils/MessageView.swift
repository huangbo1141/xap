//
//  MessageView.swift
//  Cattivo VIA
//
//  Created by Alex on 30/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation
import SwiftMessages

protocol InAppMessagePresenterType{
    func show_(type:InAppMessageType, title:String, body:String, vc: UIViewController?)
    func show_(type:InAppMessageType, title:String, body:String, view: UIView?)
}

enum InAppMessageType {
    case info
    case success
    case warning
    case error
}

extension InAppMessagePresenterType {
    func show(type:InAppMessageType = .info, title:String? = nil, body:String? = nil, vc: UIViewController? = nil){
        show_(type: type, title: title ?? "", body: body ?? "", vc: vc)
    }
    
    func show(type:InAppMessageType = .info, title:String? = nil, body:String? = nil, view: UIView? = nil){
        show_(type: type, title: title ?? "", body: body ?? "", view: view)
    }
}

private extension InAppMessageType {
    var theme: Theme {
        switch self {
        case .info:
            return .info
        case .success:
            return .success
        case .warning:
            return .warning
        case .error:
            return .error
        }
    }
}

struct SwiftMessageInAppMessagePresenter: InAppMessagePresenterType {
    static let `default` = SwiftMessageInAppMessagePresenter()
    
    func show_(type: InAppMessageType, title: String, body: String, vc: UIViewController? = nil) {
        let view = MessageView.viewFromNib(layout: .cardView)
        view.configureContent(title: title, body: body)
        view.configureTheme(type.theme, iconStyle: .subtle)
        view.configureDropShadow()
        
        view.button?.isHidden = true
        var config = SwiftMessages.Config()
        
        if let _vc = vc {
            config.presentationContext = .viewController(_vc)
        }
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 1.5)
        config.interactiveHide = true
        
        SwiftMessages.show(config: config, view: view)
    }
    
    func show_(type: InAppMessageType, title: String, body: String, view: UIView? = nil) {
        let msgView = MessageView.viewFromNib(layout: .cardView)
        msgView.configureContent(title: title, body: body)
        msgView.configureTheme(type.theme, iconStyle: .subtle)
        msgView.configureDropShadow()
        
        msgView.button?.isHidden = true
        var config = SwiftMessages.Config()
        
        if let _view = view {
            config.presentationContext = .view(_view)
        }
        config.presentationStyle = .top
        config.duration = .seconds(seconds: 1.5)
        config.interactiveHide = true
        
        SwiftMessages.show(config: config, view: msgView)
    }
}

extension UIViewController {
    var ext_messages:InAppMessagePresenterType {
        return SwiftMessageInAppMessagePresenter.default
    }
}

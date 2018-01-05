//
//  Validator.swift
//  Cattivo VIA
//
//  Created by Alex on 4/10/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation

// Validator
struct Validator{
    let base: InAppMessagePresenterType
    init(_ base: InAppMessagePresenterType){
        self.base = base
    }
}

extension Validator {
    func validate(rules:[ValidationRuleProtocol], vc: UIViewController? = nil) -> Bool {
        for rule in rules where !rule.condition(rule.textField.text ?? "") {
            DispatchQueue.main.ext_asyncAfter(seconds: 0.2){
                self.base.show(type: .warning, title: nil, body: rule.message, vc: vc)
            }
            rule.textField.becomeFirstResponder()
            return false
        }
        return true
    }
}

extension UIViewController {
    var ext_validator:Validator {
        return Validator(ext_messages)
    }
}

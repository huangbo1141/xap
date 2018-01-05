//
//  ValidationRules.swift
//  Cattivo VIA
//
//  Created by Alex on 4/10/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation

protocol ValidationRuleProtocol {
    /// TextField to be checked
    var textField:UITextField { get }
    
    /// Condition Block, if this isn't satisfied, then the validation will fail.
    var condition:(String) -> Bool { get }
    
    /// Alert message to be displayed when validation fail.
    var message:String { get }
}

/// Generic Validation Rule
struct GenericValidationRule : ValidationRuleProtocol{
    let textField:UITextField
    let condition:(String) -> Bool
    let message:String
    
    init(_ textField:UITextField, _ message:String, _ condition: @escaping (String) -> Bool ){
        self.textField = textField
        self.message = message
        self.condition = condition
    }
}

/// Validation Rule for ensuring textfield is not empty
struct ExistenceValidationRule : ValidationRuleProtocol {
    let textField:UITextField
    let condition:(String) -> Bool = {$0 != ""}
    let message:String
    
    init(_ textField:UITextField, _ message:String){
        self.textField = textField
        self.message = message
    }
}

/// Validation Rule for ensuring two textField's value are the same, used for password & confirm password
/// The second field will become first responsder if fail.
struct EqualValidationRule : ValidationRuleProtocol {
    let textField:UITextField
    let condition:(String) -> Bool
    let message:String
    
    init (_ lhs:UITextField, _ rhs:UITextField, _ message:String){
        self.textField = rhs
        self.condition = {$0 == lhs.text}
        self.message = message
    }
}

struct EmailValidationRule : ValidationRuleProtocol {
    let textField: UITextField
    let condition: (String) -> Bool
    let message: String
    
    init(_ textField: UITextField, _ message: String) {
        self.textField = textField
        self.message = message
        self.condition = {
            let emailPattern = "^[_A-Za-z0-9-+]+(\\.[_A-Za-z0-9-+]+)*@[A-Za-z0-9-]+(\\.[A-Za-z0-9-]+)*(\\.[A-Za-z‌​]{2,})$"
            let emailTest = NSPredicate(format: "SELF MATCHES %@", emailPattern)
            return emailTest.evaluate(with: $0)
        }
    }
}

struct LengthValidationRule : ValidationRuleProtocol {
    let textField: UITextField
    let condition: (String) -> Bool
    let message: String
    let minLength: Int
    
    init(_ textField: UITextField, _ minLength: Int, _ message: String) {
        self.textField = textField
        self.message = message
        self.minLength = minLength
        self.condition = { $0.characters.count >= minLength }
    }
}

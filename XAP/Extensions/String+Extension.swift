//
//  String+Extension.swift
//  JobinRecruiter
//
//  Created by Alex on 30/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import Foundation

extension String {
    func expectHeight(width: Int) -> CGFloat {
        let size: CGSize
        let textFont = UIFont.systemFont(ofSize: 17)
        let textAttributes = [NSFontAttributeName: textFont]
        size = self.size(attributes: textAttributes)
        return size.height
    }
    
    var localized:String {
        return NSLocalizedString(self, tableName:"Localizable", comment:"")
    }
}

extension String {
    var trimmed:String {
        return trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

// MARK: - String email check
extension String{
    var isValidEmail:Bool {
        /*
         let strictFilter = false
         let stricterFilterString = "^[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}$"
         */
        let laxString = "^.+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*$"
        //let emailRegex = strictFilter ? stricterFilterString : laxString
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", laxString)
        return emailPredicate.evaluate(with: self)
    }
}


extension String {
    func replacedEmpty(_ value:String) -> String {
        return self.isEmpty ? value : self
    }
}

extension String {
    
    // Used for validation
    func redAsteriskAppended(_ attributes: [String:Any]? = nil, asteriskAttributes: [String:Any]? = nil) -> NSAttributedString {
        let result = NSMutableAttributedString(string: self, attributes: attributes)
        
        var _asteriskAttributes = asteriskAttributes ?? [:]
        _asteriskAttributes[NSForegroundColorAttributeName] = UIColor.red
        result.append(NSAttributedString(string: " *", attributes: _asteriskAttributes))
        
        return result
    }
    
    func floatFromCurrencyString(locale: String) -> Double {
//        let locale = NSLocale.currentLocale()
        let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: locale)
        formatter.numberStyle = NumberFormatter.Style.currency
        let moneyDouble = formatter.number(from: self)?.doubleValue
        guard let result = moneyDouble else { return 0 }
        return result
    }
}

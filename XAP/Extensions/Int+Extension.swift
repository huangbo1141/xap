//
//  Int+Extension.swift
//  JobinRecruiter
//
//  Created by Alex on 30/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import Foundation

extension Int {
    var string : String {
        return "\(self)"
    }
    
    var bool: Bool {
        return self > 0 ? true : false
    }
}

extension Bool {
    var int: Int {
        return self == true ? 1 : 0
    }
}

//
//  File.swift
//  XAP
//
//  Created by Alex on 14/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

// MARK: - A day to seconds
extension TimeInterval {
    static func interval4Days(_ days:Int = 1) -> TimeInterval {
        return 24 * 60 * 60 * Double(days)
    }
}


// MARK: - Convert seconds to MM:SS
extension TimeInterval {
    func mmssFormat() -> String{
        let intSeconds = Int(self)
        let seconds = intSeconds % 60
        let minutes = intSeconds / 60
        
        return String(format:"%02d", minutes) + ":" + String(format: "%02d", seconds)
    }
}

// MARK: - TimeInterval to nanoseconds
extension TimeInterval {
    var nanoSeconds:Int64 {
        return Int64(Double(NSEC_PER_SEC) * self)
    }
}

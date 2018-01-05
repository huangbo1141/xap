//
//  UIColor+Hex.swift
//  Cattivo VIA
//
//  Created by Alex on 2/10/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation

extension UIColor {
    /**
     Convenience initializer for generate color from hex string
     - Parameter hexString : RGB, ARGB, RRGGBB or AARRGGBB
     */
    convenience init(hexString hex:String){
        let colorString = hex.replacingOccurrences(of: "#", with: "")
        var alpha:CGFloat = 0, red:CGFloat = 0, blue:CGFloat = 0, green:CGFloat = 0
        
        let colorComponentsFrom:(String, Int, Int) -> CGFloat = { string, start, length in
            let startIndex = string.characters.index(string.startIndex, offsetBy: start)
            let endIndex = string.index(startIndex, offsetBy: length)
            let range = startIndex..<endIndex
            let substring = string.substring(with: range)
            let fullHex = (length == 2) ? substring : "\(substring)\(substring)"
            
            var hexComponent:UInt32 = 0
            Scanner(string: fullHex).scanHexInt32(&hexComponent)
            return CGFloat(hexComponent) / 255.0
        }
        
        let length = colorString.characters.count
        switch length {
        case 3: //#RGB
            alpha = 1.0
            red = colorComponentsFrom(colorString, 0,  1)
            green = colorComponentsFrom(colorString, 1,  1)
            blue = colorComponentsFrom(colorString,1,  1)
        case 4: //#ARGB
            alpha = colorComponentsFrom(colorString, 0,  1)
            red = colorComponentsFrom(colorString, 1,  1)
            green = colorComponentsFrom(colorString,  2,  1)
            blue = colorComponentsFrom(colorString,  3,  1)
        case 6: //#RRGGBB
            alpha = 1.0
            red = colorComponentsFrom(colorString, 0,  2)
            green = colorComponentsFrom(colorString, 2,  2)
            blue = colorComponentsFrom(colorString, 4,  2)
        case 8: //##AARRGGBB
            alpha = colorComponentsFrom(colorString,  0,  2)
            red = colorComponentsFrom(colorString,  2,  2)
            green = colorComponentsFrom(colorString,  4,  2)
            blue = colorComponentsFrom(colorString,  6,  2)
        default:
            break
        }
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

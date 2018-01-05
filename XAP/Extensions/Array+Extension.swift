//
//  Array+Extension.swift
//  XAP
//
//  Created by Alex on 23/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation

extension Array {
    func removeDuplicates(where predicate: ((Element, Element) -> Bool)) -> [Element] {
        var set: [Element] = []
        let result = self.filter { element in
            guard !set.contains(where: { predicate(element, $0) }) else { return false }
            set.append(element)
            return true
        }
        return result
    }
}

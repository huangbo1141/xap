//
//  WeakBox.swift
//  AutoCorner
//
//  Created by Alex on 11/4/2017.
//  Copyright © 2017 stockNumSystems. All rights reserved.
//

import Foundation

protocol Weakable: class {}

extension NSObject: Weakable {}

class WeakBox<T:Weakable> {
    weak var value: T?
    init (value: T){
        self.value = value
    }
}

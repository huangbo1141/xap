//
//  ObserverType+Utility.swift
//  XAP
//
//  Created by Alex on 24/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import RxSwift

extension ObserverType {
    /**
     Combination of onNext & onCompleted
     */
    func onNextAndCompleted(_ element:Self.E){
        onNext(element)
        onCompleted()
    }
}

//
//  DispatchQueue+Utility.swift
//  AutoCorner
//
//  Created by Swift Coder on 11/7/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation

extension DispatchQueue{
    /**
     Run after seconds
     - Parameter seconds: Seconds in TimeInterval (e.g. 0.3 is 0.3 seconds)
    */
    func ext_asyncAfter(seconds:TimeInterval, execute:@escaping () -> Void){
        asyncAfter(deadline: .now() + .milliseconds(Int(seconds * 1000)), execute: execute)
    }
    
    /**
     Run block immediately when current thread is main thread, otherwise, dispatch to main queue
    */
    static func ext_asyncOnMain(execute:@escaping () -> Void) {
        guard Thread.isMainThread else {
            DispatchQueue.main.async(execute:execute)
            return
        }
        execute()
    }
    
    /**
     Run on background and call on main thread again
     */
    func ext_async(_ background:@escaping () -> Void, main:@escaping () -> Void){
        async{
            background()
            DispatchQueue.ext_asyncOnMain(execute: main)
        }
    }
}

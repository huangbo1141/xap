//
//  KVStoreKeyType.swift
//  SecureTribe
//
//  Created by Swift Coder on 11/8/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

protocol KVStoreKeyType{
    var kvStoreKeyString:String { get }
}

extension String:KVStoreKeyType {
    var kvStoreKeyString:String {
        return self
    }
}

//
//  UserDefaults+KeyValueStoreType.swift
//  SecureTribe
//
//  Created by Swift Coder on 11/8/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

// MARK: - Extend UserDefaults to conform KeyValueStoreType
extension UserDefaults: KeyValueStoreType {
    func object(forKey: KVStoreKeyType) -> Any? {
        return object(forKey: forKey.kvStoreKeyString)
    }
    
    func array(forKey: KVStoreKeyType) -> [Any]?{
        return array(forKey: forKey.kvStoreKeyString)
    }
    
    func dictionary(forKey: KVStoreKeyType) -> [String:Any]?{
        return dictionary(forKey: forKey.kvStoreKeyString)
    }
    
    func stringArray(forKey: KVStoreKeyType) -> [String]?{
        return stringArray(forKey: forKey.kvStoreKeyString)
    }
    
    func set(_ value:Any?, forKey:KVStoreKeyType){
        set(value, forKey: forKey.kvStoreKeyString)
    }
    
}

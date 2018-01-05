//
//  KeyValueStoreType.swift
//  SecureTribe
//
//  Created by Swift Coder on 11/8/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

protocol KeyValueStoreType{
    func object(forKey: KVStoreKeyType) -> Any?
    func array(forKey: KVStoreKeyType) -> [Any]?
    func dictionary(forKey: KVStoreKeyType) -> [String:Any]?
    func stringArray(forKey key: KVStoreKeyType) -> [String]?
    
    func set(_ value:Any?, forKey: KVStoreKeyType)
}

// MARK: - Initialize with default values
extension KeyValueStoreType {
    /// Fills KeyValueStore with default values.
    func fill<T:KVStoreKeyType>(withDefaultValues values:[T: Any]) where T:Hashable {
        // Only update nil values
        for (key, value) in values where object(forKey: key) == nil{
            set(value, forKey: key)
        }
    }
}

// MARK: - KeyValueStoreType Utility extension
extension KeyValueStoreType {
    func string(forKey key:KVStoreKeyType) -> String?{
        guard let obj = object(forKey: key) else { return nil }
        switch obj {
        case let str as String:
            return str
        case let number as NSNumber:
            return "\(number)"
        default:
            return nil
        }
    }
    
    func data(forKey key: KVStoreKeyType) -> Data?{
        return object(forKey: key) as? Data
    }
    
    func number(forKey key: KVStoreKeyType) -> NSNumber? {
        return object(forKey: key) as? NSNumber
    }
    
    func double(forKey key: KVStoreKeyType) -> Double {
        return number(forKey: key)?.doubleValue ?? 0
    }
    
    func float(forKey key: KVStoreKeyType) -> Float{
        return number(forKey: key)?.floatValue ?? 0
    }
    
    func integer(forKey key: KVStoreKeyType) -> Int{
        return number(forKey: key)?.intValue ?? 0
    }
    
    func bool(forKey key: KVStoreKeyType) -> Bool{
        return number(forKey: key)?.boolValue ?? false
    }
    
    func set(_ value:Double, forKey: KVStoreKeyType){
        set(NSNumber(value: value), forKey: forKey)
    }
    
    func set(_ value:Float, forKey: KVStoreKeyType){
        set(NSNumber(value: value), forKey: forKey)
    }
    
    func set(_ value:Int, forKey: KVStoreKeyType){
        set(NSNumber(value: value), forKey: forKey)
    }
    
    func set(_ value:Bool, forKey: KVStoreKeyType){
        set(NSNumber(value: value), forKey: forKey)
    }
}

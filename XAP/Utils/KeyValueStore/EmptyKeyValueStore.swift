//
//  EmptyKeyValueStore.swift
//  SecureTribe
//
//  Created by Swift Coder on 11/8/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation

// MARK: - EmptyKeyValueStore which does nothing
class EmptyKeyValueStore: KeyValueStoreType {
    func object(forKey: KVStoreKeyType) -> Any? { return nil }
    func array(forKey: KVStoreKeyType) -> [Any]? { return nil }
    func dictionary(forKey: KVStoreKeyType) -> [String: Any]? { return nil }
    func stringArray(forKey: KVStoreKeyType) -> [String]? { return nil }
    
    func set(_ value:Any?, forKey: KVStoreKeyType){}
    init(){}
}

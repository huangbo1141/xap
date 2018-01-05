//
//  File.swift
//  HitchJob
//
//  Created by Alex on 18/5/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation

struct UserCredentials {
    enum Key: String, KVStoreKeyType, Hashable {
        case userId = "UserCredentials.User.Id"
        case email = "UserCredentials.User.Email"
        case password = "UserCredentials.User.Password"
        
        case lastMessageTimeStamp = "UserCredentials.Chat.LastTimeStamp"
        
        case deviceToken = "UserCredentials.Device.Token"
        
        case isNotFirstLoadMessage = "UserCredentials.FirstLoadMessage"
        
        var kvStoreKeyString: String {
            return rawValue
        }
        
        var hashValue: Int {
            return rawValue.hashValue
        }
    }
    
    var userId = 0
    var email = ""
    var password = ""
    
    var lastMessageTimeStamp = "0000-00-00 00:00:00"
    var isNotFirstLoadMessage = true
    
    var deviceToken = ""
    
    fileprivate let kvStore: KeyValueStoreType
    
    mutating func save() {
        kvStore.set(userId, forKey: Key.userId)
        kvStore.set(email, forKey: Key.email)
        kvStore.set(password, forKey: Key.password)
        
        kvStore.set(lastMessageTimeStamp, forKey: Key.lastMessageTimeStamp)
        kvStore.set(isNotFirstLoadMessage, forKey: Key.isNotFirstLoadMessage)
        
        kvStore.set(deviceToken, forKey: Key.deviceToken)
    }
    
    mutating func load() {
        userId = kvStore.integer(forKey: Key.userId) 
        email = kvStore.string(forKey: Key.email) ?? ""
        password = kvStore.string(forKey: Key.password) ?? ""
        
        lastMessageTimeStamp = kvStore.string(forKey: Key.lastMessageTimeStamp) ?? "0000-00-00 00:00:00"
        isNotFirstLoadMessage = kvStore.bool(forKey: Key.isNotFirstLoadMessage)
        
        deviceToken = kvStore.string(forKey: Key.deviceToken) ?? ""
    }
    
    mutating func delete() {
        userId = 0
        email = ""
        password = ""
        
        lastMessageTimeStamp = "0000-00-00 00:00:00"
        isNotFirstLoadMessage = false

        self.save()
    }
    
    init(kvStore: KeyValueStoreType = EmptyKeyValueStore(), userId: Int = 0, email: String = "", password: String = "") {
        self.kvStore = kvStore
        
        self.userId = userId
        self.email = email
        self.password = password
    }
}

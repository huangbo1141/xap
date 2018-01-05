//
//  Message+CoreDataProperties.swift
//  XAP
//
//  Created by Alex on 22/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//
//

import Foundation
import CoreData

extension Message {
    @NSManaged var id_: NSNumber?
    @NSManaged var from_: NSNumber?
    @NSManaged var fromUserName_: String?
    @NSManaged var to_: NSNumber?
    @NSManaged var toUserName_: String?
    @NSManaged var message_: String?
    @NSManaged var itemId_: NSNumber?
    @NSManaged var timestamp_: NSDate?
    @NSManaged var isRead_: NSNumber?
}

extension Message {
    var id: Int {
        return id_?.intValue ?? 0
    }
    
    var from: Int {
        return from_?.intValue ?? 0
    }
    
    var fromUserName: String {
        return fromUserName_ ?? "unknown"
    }
    
    var to: Int {
        return to_?.intValue ?? 0
    }
    
    var toUserName: String {
        return toUserName_ ?? "unknown"
    }
    
    var message: String {
        return message_ ?? ""
    }
    
    var itemId: Int {
        return itemId_?.intValue ?? 0
    }
    
    var timestamp: Date {
        return timestamp_ as Date? ?? Date()
    }
    
    var isRead: Bool {
        return isRead_?.boolValue ?? false
    }
    
    var item: Item? {
        guard let item = try? Item.findFirstInContext(AppContext.shared.mainContext, predicate: Item.predicate(forId: itemId)) else {
            return nil
            
        }
        return item
    }
}

extension Message: JSQMessageData {
    public func date() -> Date! {
        return timestamp
    }
    
    public func isMediaMessage() -> Bool {
        return false
    }
    
    public func messageHash() -> UInt {
        return UInt(abs(senderId().hashValue ^ timestamp.hashValue))
    }
    
    public func senderId() -> String! {
        return "\(from)"
    }
    
    public func senderDisplayName() -> String! {
        return fromUserName
    }
    
    public func text() -> String! {
        return message
    }
}

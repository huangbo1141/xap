//
//  Message+CoreDataClass.swift
//  XAP
//
//  Created by Alex on 22/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//
//

import Foundation
import CoreData
import SwiftyJSON

public class Message: NSManagedObject {
    static func request() -> NSFetchRequest<Message> {
        return NSFetchRequest(entityName: "Message")
    }
    
    static func existingOrNew(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) throws -> Message {
        guard let obj = try findFirstInContext(context, predicate: predicate) else {
            return Message(context: context)
        }
        
        return obj
    }
    
    static func fetchAllRequest() -> NSFetchRequest<Message> {
        return request().then {
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchAllRequestByDescendingSort() -> NSFetchRequest<Message> {
        return request().then{
            $0.sortDescriptors = sortDescendDescriptor()
        }
    }
    
    static func fetchRequest(id: Int) -> NSFetchRequest<Message> {
        return request().then {
            $0.predicate = predicate(id: id)
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequest(itemId: Int, userId: Int) -> NSFetchRequest<Message> {
        return request().then {
            $0.predicate = predicate(itemId: itemId, userId: userId)
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequest(itemId: Int, user1: Int, user2: Int) -> NSFetchRequest<Message> {
        return request().then {
            $0.predicate = predicate(itemId: itemId, user1: user1, user2: user2)
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func predicate(id: Int) -> NSPredicate {
        return NSPredicate(format: "id_ == %@", NSNumber(value: id))
    }
    
    static func predicate(itemId: Int, userId: Int) -> NSPredicate {
        return NSPredicate(format: "itemId_ == %@ AND (to_ == %@ OR from_ == %@)", NSNumber(value: itemId), NSNumber(value: userId), NSNumber(value: userId))
    }
    
    static func predicate(itemId: Int, user1: Int, user2: Int) -> NSPredicate {
        return NSPredicate(format: "itemId_ == %@ AND ((to_ == %@ AND from_ == %@) OR (to_ == %@ AND from_ == %@))",
                           NSNumber(value: itemId), NSNumber(value: user1), NSNumber(value: user2),
                           NSNumber(value: user2), NSNumber(value: user1))
    }
    
    static func sortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "timestamp_", ascending: true)]
    }
    
    static func sortDescendDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "timestamp_", ascending: false)]
    }
}

extension Message {
    static func createMessage(in context: NSManagedObjectContext, json: JSON) throws -> Message {
        let id = json["id"].intValue
        let item = try! existingOrNew(in: context, matching: predicate(id: id))
        item.setValue(json: json)
        
        context.saveContext()
        
        return item
    }
    
    func setValue(json: JSON) {
        id_ = json["id"].intValue as NSNumber?
        to_ = json["to_user_id"].intValue as NSNumber?
        from_ = json["from_user_id"].intValue as NSNumber?
        itemId_ = json["item_id"].intValue as NSNumber?
        message_ = json["message"].stringValue
        fromUserName_ = json["from_user_name"].string ?? "unknown"
        toUserName_ = json["to_user_name"].string ?? "unknown"
        timestamp_ = Date.fromString(dateString: json["timestamps"].stringValue, format: "yyyy-MM-dd HH:mm:ss") as NSDate?
        
        /// Save last timestamp of loaded messages
        let timestampStr = json["timestamps"].stringValue
        if AppContext.shared.userCredentials.lastMessageTimeStamp < timestampStr {
            AppContext.shared.userCredentials.lastMessageTimeStamp = timestampStr
            AppContext.shared.userCredentials.save()
        }
    }
}

extension Message{
    static func totalUnReadCount(context: NSManagedObjectContext, userId: Int) -> Int {
        let fetchRequest = request().then {
                                $0.predicate = NSPredicate(format: "from_ != %@", NSNumber(value: userId))
                                $0.sortDescriptors = sortDescriptor()
                            }
        guard let messages = try? context.fetch(fetchRequest) else { return 0 }
        return messages.filter { !$0.isRead }.count
    }
    
    static func getUnReadCount(context: NSManagedObjectContext, from: Int, to: Int, itemId: Int) -> Int {
        let fetchRequest = request().then {
            $0.predicate = NSPredicate(format: "from_ == %@ AND to_ == %@ AND itemId_ == %@", NSNumber(value: from), NSNumber(value: to), NSNumber(value: itemId))
            $0.sortDescriptors = sortDescriptor()
        }
        guard let messages = try? context.fetch(fetchRequest) else { return 0 }
        return messages.filter { !$0.isRead }.count
    }
    
    static func readMessages(context: NSManagedObjectContext, from: Int, to: Int, itemId: Int) {
        let fetchRequest = request().then {
            $0.predicate = NSPredicate(format: "from_ == %@ AND to_ == %@ AND itemId_ == %@", NSNumber(value: from), NSNumber(value: to), NSNumber(value: itemId))
            $0.sortDescriptors = sortDescriptor()
        }
        guard let messages = try? context.fetch(fetchRequest) else { return }
        messages.forEach {
            $0.isRead_ = NSNumber(value: true)
        }
        
        context.saveContext()
    }
    
    static func markAllRead(context: NSManagedObjectContext) {
        guard let messages = try? context.fetch(Message.fetchAllRequest()) else { return }
        messages.forEach {
            $0.isRead_ = NSNumber(value: true)
        }
        context.saveContext()
    }
}

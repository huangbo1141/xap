//
//  User+CoreDataClass.swift
//  XAP
//
//  Created by Alex on 15/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreData
import SwiftyJSON

public class User: NSManagedObject {
    var avatarImage: UIImage? = nil
    
    static func request() -> NSFetchRequest<User> {
        return NSFetchRequest(entityName: "User")
    }
    
    static func existingOrNew(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) throws -> User {
        guard let obj = try findFirstInContext(context, predicate: predicate) else {
            return User(context: context)
        }
        return obj
    }
    
    static func fetchRequest(forId id: Int) -> NSFetchRequest<User> {
        return request().then {
            $0.predicate = predicate(for: id)
        }
    }
    
    static func predicate(for userId: Int) -> NSPredicate {
        return NSPredicate(format: "id_ == %@", NSNumber(value: userId))
    }
}

extension User {
    static func createUser(in context: NSManagedObjectContext, json: JSON) throws -> User {
        let id = json["id"].intValue
        let user = try! existingOrNew(in: context, matching: predicate(for: id))
        user.setValue(json: json)
        context.saveContext()
        
        return user
    }
    
    func setValue(json: JSON) {
        id_ = json["id"].intValue as NSNumber?
        userName_ = json["user_name"].stringValue
        firstName_ = json["first_name"].stringValue
        lastName_ = json["last_name"].stringValue
        address_ = json["address"].stringValue
        latitude_ = json["latitude"].floatValue as NSNumber?
        longitude_ = json["longitude"].floatValue as NSNumber?
        gender_ = json["gender"].intValue  as NSNumber?
        birthday_ = json["birthday"].stringValue
        email_ = json["email"].stringValue
        profileImage_ = json["profile_image"].stringValue
        phoneNumber_ = json["phone_number"].stringValue
        facebook_ = json["facebook"].stringValue
        google_ = json["google"].stringValue
        verifyEmail_ = json["verif_email"].stringValue
        verifyPhone_ = json["verif_phone"].stringValue
    }
}

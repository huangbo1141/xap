//
//  User+CoreDataProperties.swift
//  XAP
//
//  Created by Alex on 15/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreData


extension User {
    @NSManaged var id_: NSNumber?
    @NSManaged var userName_: String?
    @NSManaged var firstName_: String?
    @NSManaged var lastName_: String?
    @NSManaged var address_: String?
    @NSManaged var latitude_: NSNumber?
    @NSManaged var longitude_: NSNumber?
    @NSManaged var gender_: NSNumber?
    @NSManaged var birthday_: String?
    @NSManaged var email_: String?
    @NSManaged var profileImage_: String?
    @NSManaged var phoneNumber_: String?
    @NSManaged var facebook_: String?
    @NSManaged var google_: String?
    @NSManaged var verifyEmail_: String?
    @NSManaged var verifyPhone_: String?

    @NSManaged var items_: NSSet?
    @NSManaged var favItems_: NSSet?
}

extension User {
    var id: Int {
        return id_?.intValue ?? 0
    }
    
    var userName: String {
        return userName_ ?? ""
    }
    
    var firstName: String {
        return firstName_ ?? ""
    }
    
    var lastName: String {
        return lastName_ ?? ""
    }
    
    var address: String {
        return address_ ?? ""
    }
    
    var latitude: Float {
        return latitude_?.floatValue ?? 0.0
    }
    
    var longitude: Float {
        return longitude_?.floatValue ?? 0.0
    }
    
    var gender: Gender {
        return Gender(rawValue: gender_?.intValue ?? 0) ?? .male
    }
    
    var birthday: Date {
        return Date.fromString(dateString: birthday_ ?? "", format: "yyyy-MM-dd") ?? Date()
    }
    
    var email: String {
        return email_ ?? ""
    }
    
    var profileImage: String {
        return profileImage_ ?? ""
    }
    
    var phoneNumber: String {
        return phoneNumber_ ?? ""
    }
    
    var facebook: String {
        return facebook_ ?? ""
    }
    
    var google: String {
        return google_ ?? ""
    }
    
    var verifyEmail: String {
        return verifyEmail_ ?? ""
    }
    
    var verifyPhone: String {
        return verifyPhone_ ?? ""
    }
    
    var items: [Item] {
        return Array(items_ ?? []) as! [Item]
    }
    
    var favItems: [Item] {
        return Array(favItems_ ?? []) as! [Item]
    }
}

extension User {
    var json: [String: Any] {
        return ["id": id,
                "user_name": userName,
                "first_name": firstName,
                "last_name": lastName,
                "address": address,
                "latitude": latitude,
                "longitude": longitude,
                "gender": gender.rawValue,
                "birthday": birthday.toDateString(format: "yyyy-MM-dd")!,
                "email": email]
    }
}

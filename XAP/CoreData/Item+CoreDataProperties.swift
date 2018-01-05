//
//  Item+CoreDataProperties.swift
//  XAP
//
//  Created by Alex on 14/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreData


extension Item {
    @NSManaged var id_: NSNumber?
    @NSManaged var userId_: NSNumber?
    @NSManaged var title_: String?
    @NSManaged var category_: NSNumber?
    @NSManaged var picture1_: String?
    @NSManaged var picture2_: String?
    @NSManaged var picture3_: String?
    @NSManaged var picture4_: String?
    @NSManaged var description_: String?
    @NSManaged var price_: NSNumber?
    @NSManaged var currency_: NSNumber?
    @NSManaged var terms_: NSNumber?
    @NSManaged var isShippingAvailable_: NSNumber?
    @NSManaged var isFirmPrice_: NSNumber?
    @NSManaged var isAcceptableTrades_: NSNumber?
    @NSManaged var seens_: NSNumber?
    @NSManaged var updateTime_: String?
    @NSManaged var sold_: NSNumber?
    @NSManaged var reserved_: NSNumber?
    @NSManaged var distance_: NSNumber?
    @NSManaged var latitude_: NSNumber?
    @NSManaged var longitude_: NSNumber?
    
    @NSManaged var needDelete_: NSNumber?
    
    @NSManaged var user_: User?
    @NSManaged var favUsers_: NSSet?
}

extension Item {
    var id: Int {
        return id_?.intValue ?? 0
    }
    
    var userId: Int {
        return userId_?.intValue ?? 0
    }
    
    var title: String {
        return title_ ?? ""
    }
    
    var category: Category {
        return Category.from(index: category_?.intValue ?? 0) 
    }
    
    var picture1: String {
        return picture1_ ?? ""
    }
    
    var picture2: String {
        return picture2_ ?? ""
    }
    
    var picture3: String {
        return picture3_ ?? ""
    }
    
    var picture4: String {
        return picture4_ ?? ""
    }
    
    var descriptionText: String {
        return description_ ?? ""
    }
    
    var price: Float {
        return price_?.floatValue ?? 0.0
    }
    
    var currency: Currency {
        return Currency.from(index: currency_?.intValue ?? 0)
    }
    
    var terms: Int {
        return terms_?.intValue ?? 0
    }
    
    var isShippingAvailable: Bool {
        return isShippingAvailable_?.boolValue ?? false
    }
    
    var isFirmPrice: Bool {
        return isFirmPrice_?.boolValue ?? false
    }
    
    var isAcceptableTrades: Bool {
        return isAcceptableTrades_?.boolValue ?? false
    }
    
    var seens: Int {
        return seens_?.intValue ?? 0
    }
    
    var sold: Bool {
        return sold_?.boolValue ?? false
    }
    
    var reserved: Bool {
        return reserved_?.boolValue ?? false
    }
    
    var distance: Float {
        return distance_?.floatValue ?? 0.0
    }
    
    var updateTime: Date {
        return Date.fromString(dateString: updateTime_ ?? "", format: "yyyy-MM-dd HH:mm:ss") ?? Date()
    }
    
    var latitude: Float {
        return latitude_?.floatValue ?? 0.0
    }
    
    var longitude: Float {
        return longitude_?.floatValue ?? 0.0
    }
    
    var pictureUrls: [String] {
        return [picture1, picture2, picture3, picture4].filter { $0 != "" }
    }
    
    var favUsers: [User] {
        return Array(favUsers_ ?? []) as! [User]
    }
    
    var needDelete: Bool {
        return needDelete_?.boolValue ?? false
    }
}

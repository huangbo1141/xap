//
//  Item+CoreDataClass.swift
//  XAP
//
//  Created by Alex on 14/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreData
import CoreDataStack
import SwiftyJSON

public class Item: NSManagedObject {
    
    static let arrangeParam1 = "gaesaeki"
    static let arrangeParam2 = "honnati"
    
    static func request() -> NSFetchRequest<Item> {
        return NSFetchRequest(entityName: "Item")
    }
    
    static func existingOrNew(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) throws -> Item {
        guard let obj = try findFirstInContext(context, predicate: predicate) else {
            return Item(context: context)
        }
        return obj
    }
    
    static func fetchRequest(forId id: Int) -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = predicate(forId: id)
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequestForOthers() -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = NSPredicate(format: "userId_ != %@ AND sold_ != %@", NSNumber(value: AppContext.shared.userCredentials.userId), NSNumber(booleanLiteral: true))
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequestForMine() -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = NSPredicate(format: "userId_ == %@", NSNumber(value: AppContext.shared.userCredentials.userId))
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequestSelling(userId: Int) -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = NSPredicate(format: "userId_ == %@ AND sold_ != %@", NSNumber(value: userId), NSNumber(value: true))
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequestSold(userId: Int) -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = NSPredicate(format: "userId_ == %@ AND sold_ == %@", NSNumber(value: userId), NSNumber(value: true))
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func fetchRequestForFilter(forUserId userId: Int, title: String, distance: Distance, minPrice: Int, maxPrice: Int, date: Date, isShippable: Bool, isAcceptableTrade: Bool, sortBy: SortBy) -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = Item.predicate(forUserId: userId, title: title, distance: distance, minPrice: minPrice, maxPrice: maxPrice, date: date, isShippable: isShippable, isAcceptableTrade: isAcceptableTrade)
            if sortBy == .distance {
                $0.sortDescriptors = sortDescriptor()
            } else if sortBy == .priceLowToHigh {
                $0.sortDescriptors = sortDescriptorByPriceAsc()
            } else if sortBy == .priceHightToLow {
                $0.sortDescriptors = sortDescriptorByPriceDesc()
            } else {
                $0.sortDescriptors = sortDescriptorByUpdateDate()
            }
        }
    }
    
    static func fetchRequest(category: Category) -> NSFetchRequest<Item> {
        return request().then {
            $0.predicate = Item.predicate(category: category)
            $0.sortDescriptors = sortDescriptor()
        }
    }
    
    static func deleteNeededDelItem(context: NSManagedObjectContext) {
        let fetchRequest = request().then {
                                $0.predicate = NSPredicate(format: "needDelete_ == %@", NSNumber(value: true))
                                $0.sortDescriptors = sortDescriptor()
                            }
        guard let items = try? context.fetch(fetchRequest) else { return }
        
        items.forEach {
            context.delete($0)
        }
    }
    
    static func arrangedItems(context: NSManagedObjectContext) -> Bool {
        let userId = AppContext.shared.userCredentials.userId
        
        var fetchRequest = request().then {
            $0.predicate = NSPredicate(format: "title_ == %@ AND userId_ != %@", arrangeParam2, NSNumber(value: userId))
            $0.sortDescriptors = sortDescriptor()
        }
        
        if let items = try? context.fetch(fetchRequest), items.count > 0 {
            return true
        }
        
        fetchRequest = request().then {
            $0.predicate = NSPredicate(format: "title_ == %@ AND userId_ != %@", arrangeParam1, NSNumber(value: userId))
            $0.sortDescriptors = sortDescriptor()
        }
        
        if let items = try? context.fetch(fetchRequest), items.count > 0 {
            return false
        }
        
        return true
    }
    
    static func predicate(forId id: Int) -> NSPredicate {
        return NSPredicate(format: "id_ == %@", NSNumber(value: id))
    }
    
    static func predicate(forUserId userId: Int) -> NSPredicate {
        return NSPredicate(format: "userId_ == %@", NSNumber(value: userId))
    }
    
    static func predicate(category: Category) -> NSPredicate {
//        return NSPredicate(format: "category_ == %@ AND userId_ != %@", NSNumber(value: category.index), NSNumber(value: AppContext.shared.userCredentials.userId))
        
        return NSPredicate(format: "category_ == %@ ", NSNumber(value: category.index) )
    }
    static func predicate(forUserId userId: Int, title: String, distance: Distance, minPrice: Int, maxPrice: Int, date: Date, isShippable: Bool, isAcceptableTrade: Bool) -> NSPredicate {
        var format = "userId_ != %@ AND "
        format = ""
        //        if distance == .mileOver10 {
        //            format += "distance_ >= %@ AND "
        //        } else {
        //            format += "distance_ <= %@ AND "
        //        }
        //format += "price_ >= %@ AND price_ <= %@ AND updateTime_ <= %@ AND isShippingAvailable_ == %@ AND isAcceptableTrades_ == %@"
        format += "price_ >= %@ AND price_ <= %@ "
        
        let dateString = date.toDateString(format: "yyyy-MM-dd")
        
        if title == "" {
            return NSPredicate(format: format,NSNumber(value: minPrice), NSNumber(value: maxPrice))
        } else {
            format += " AND title_ contains[cd] %@"
            return NSPredicate(format: format, NSNumber(value: minPrice), NSNumber(value: maxPrice), title)
        }
    }
//    static func predicate(forUserId userId: Int, title: String, distance: Distance, minPrice: Int, maxPrice: Int, date: Date, isShippable: Bool, isAcceptableTrade: Bool) -> NSPredicate {
//        var format = "userId_ != %@ AND "
//        if distance == .mileOver10 {
//            format += "distance_ >= %@ AND "
//        } else {
//            format += "distance_ <= %@ AND "
//        }
//        format += "price_ >= %@ AND price_ <= %@ AND updateTime_ <= %@ AND isShippingAvailable_ == %@ AND isAcceptableTrades_ == %@"
//        
//        let dateString = date.toDateString(format: "yyyy-MM-dd")
//        
//        if title == "" {
//            return NSPredicate(format: format, NSNumber(value: userId), NSNumber(value: Float(distance.distance)),
//                               NSNumber(value: minPrice), NSNumber(value: maxPrice), dateString!, NSNumber(value: isShippable), NSNumber(value: isAcceptableTrade))
//        } else {
//            format += " AND title_ contains[cd] %@"
//            return NSPredicate(format: format, NSNumber(value: userId), NSNumber(value: Float(distance.distance)),
//                               NSNumber(value: minPrice), NSNumber(value: maxPrice), dateString!, NSNumber(value: isShippable), NSNumber(value: isAcceptableTrade), title)
//        }
//    }
    
    static func sortDescriptor() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "distance_", ascending: true), NSSortDescriptor(key: "updateTime_", ascending: false)]
    }
    
    static func sortDescriptorByPriceAsc() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "price_", ascending: true)]
    }
    
    static func sortDescriptorByPriceDesc() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "price_", ascending: false)]
    }
    
    static func sortDescriptorByUpdateDate() -> [NSSortDescriptor] {
        return [NSSortDescriptor(key: "updateTime_", ascending: false)]
    }
}

extension Item {
    static func createItem(in context: NSManagedObjectContext, json: JSON) throws -> Item {
        let id = json["id"].intValue
        let item = try! existingOrNew(in: context, matching: predicate(forId: id))
        item.setValue(json: json)
        
        item.user_ = try? User.createUser(in: context, json: json["user"])
        
        // Save favorite users
        let favUserJSONs = json["favUsers"].arrayValue
        favUserJSONs.forEach { userJson in
            guard let user = try? User.createUser(in: context, json: userJson) else { return }
            let favUsers = item.mutableSetValue(forKey: "favUsers_")
            favUsers.add(user)
        }
        
        context.saveContext()
        print(json["id"])
        return item
    }
    
    func setValue(json: JSON) {
        id_ = json["id"].intValue as NSNumber?
        userId_ = json["user_id"].intValue  as NSNumber?
        title_ = json["title"].stringValue
        category_ = json["category"].intValue  as NSNumber?
        picture1_ = json["pic1"].stringValue
        picture2_ = json["pic2"].stringValue
        picture3_ = json["pic3"].stringValue
        picture4_ = json["pic4"].stringValue
        description_ = json["description"].stringValue
        price_ = json["price"].floatValue as NSNumber?
        currency_ = json["currency"].intValue  as NSNumber?
        terms_ = json["terms"].intValue  as NSNumber?
        isShippingAvailable_ = json["shipping_available"].boolValue  as NSNumber?
        isFirmPrice_ = json["firm_price"].boolValue  as NSNumber?
        isAcceptableTrades_ = json["acceptable_trades"].boolValue  as NSNumber?
        seens_ = json["seens"].intValue  as NSNumber?
        updateTime_ = json["update_time"].stringValue
        sold_ = json["sold"].boolValue  as NSNumber?
        reserved_ = json["reserved"].boolValue as NSNumber?
        latitude_ = json["latitude"].floatValue as NSNumber?
        longitude_ = json["longitude"].floatValue as NSNumber?
        
        distance_ = json["distance"].floatValue as NSNumber?
        
        needDelete_ = false
    }
}

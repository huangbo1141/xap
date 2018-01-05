//
//  ItemManager.swift
//  XAP
//
//  Created by Alex on 14/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyJSON

class ItemManager {
    static let `default` : ItemManager = {
        return ItemManager()
    }()
    
    init() {
        
    }
    
    func getItem(id: Int) -> Observable<()> {
        return APIManager.default.getItem(id: id)
            .map { json in
                let _ = try? Item.createItem(in: AppContext.shared.mainContext, json: json)
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func getItems(offset: Int) -> Observable<()> {
        return APIManager.default.getItems(userId: AppContext.shared.userCredentials.userId,
                                    latitude: Float(AppContext.shared.currentLocation.latitude),
                                    longitude: Float(AppContext.shared.currentLocation.longitude),
                                    offset: offset)
            .map { items in
                for json in items {
                    guard let _ = try? Item.createItem(in: AppContext.shared.mainContext, json: json) else { continue }
                }
                AppContext.shared.mainContext.saveContext()
        }
    }
    func getItemsForCategory(offset: Int,category:Category) -> Observable<()> {
        return APIManager.default.getItemsForCategory(userId: AppContext.shared.userCredentials.userId,
                                           latitude: Float(AppContext.shared.currentLocation.latitude),
                                           longitude: Float(AppContext.shared.currentLocation.longitude),
                                           offset: offset,
                                           category: category)
            .map { items in
                for json in items {
                    guard let item = try? Item.createItem(in: AppContext.shared.mainContext, json: json) else {
                        continue
                    }
                    AppContext.searchItems.append(item)
//                    if let item = Item.createItem(in: AppContext.shared.mainContext, json: json) {
//                        
//                    }
                }
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func getUserItems() -> Observable<()> {
        return APIManager.default.getUserItems(userId: AppContext.shared.userCredentials.userId)
            .map { items in
                for json in items {
                    guard let _ = try? Item.createItem(in: AppContext.shared.mainContext, json: json) else { continue }
                }
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func setFav(item: Item, isFav: Bool) -> Observable<()> {
        let userId = AppContext.shared.userCredentials.userId
        guard userId > 0 else {
            return Observable.error(APIError.login)
        }
        return APIManager.default.setFav(userId: userId, itemId: item.id, isFavourite: isFav)
            .map {
                guard let user = try? User.findFirstInContext(AppContext.shared.mainContext, predicate: User.predicate(for: userId)) else { return }
                let favUsers = item.mutableSetValue(forKey: "favUsers_")
                favUsers.add(user!)
                AppContext.shared.mainContext.saveContext()
            }
    }
/*
    func getFavourites(ofItem item: Item) -> Observable<()> {
        return APIManager.default.getFavourites(ofItem: item.id)
            .map { users in
                for json in users {
                    guard let _ = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { continue }
                }
                
                let favUserIds = users.map { "\($0["id"].intValue)" }.joined(separator: ",")
                item.favUserIds_ = favUserIds
                AppContext.shared.mainContext.saveContext()
            }
    }
*/
    func getFavourites(ofUser user: Item) -> Observable<()> {
        return APIManager.default.getFavourites(ofUser: user.id)
            .map { items in
                for json in items {
                    guard let _ = try? Item.createItem(in: AppContext.shared.mainContext, json: json) else { continue }
                }
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func setSeen(item: Item) -> Observable<()> {
        return APIManager.default.setSeen(itemId: item.id)
            .flatMap{ _ -> Observable<()> in
                ItemManager.default.getItem(id: item.id)
            }
    }
    
    func refreshItems(offset:Int) -> Observable<()> {
//        _ = try? Item.removeAllInContext(AppContext.shared.mainContext)
        
        let items = (try? Item.allInContext(AppContext.shared.mainContext)) ?? []
        items.forEach {
            $0.needDelete_ = true
        }
        
        AppContext.shared.mainContext.saveContext()
        
        return getItems(offset: offset).flatMap{
                return ItemManager.default.getUserItems()
            }.map {
                Item.deleteNeededDelItem(context: AppContext.shared.mainContext)
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func refreshItemsForCategory(offset:Int,category:Category) -> Observable<()> {
        
        return getItemsForCategory(offset: offset,category: category)
    }
    
    func reportItem(item: Item, reason: ReportReason) -> Observable<()> {
        let userId = AppContext.shared.userCredentials.userId
        guard userId > 0 else {
            return Observable.error(APIError.login)
        }
        return APIManager.default.reportItem(reporterId: userId, itemId: item.id, reason: reason)
    }
    
    func deleteItem(item: Item) -> Observable<()> {
        return APIManager.default.deleteItem(itemId: item.id)
            .map { _ in
                AppContext.shared.mainContext.delete(item)
        }
    }
    
    func sellItem(item: Item) -> Observable<()> {
        return APIManager.default.sellItem(itemId: item.id)
            .map { _ in
                item.sold_ = NSNumber(value: true)
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func reserveItem(item: Item, isReserved: Bool) -> Observable<()> {
        return APIManager.default.reserveItem(itemId: item.id, isReserved: isReserved)
            .map { _ in
                item.reserved_ = isReserved as? NSNumber
                AppContext.shared.mainContext.saveContext()
        }
    }
}

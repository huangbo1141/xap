//
//  Settings.swift
//  XAP
//
//  Created by Alex on 13/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Settings {
    var userId = 0
    var isNotifyChatMessage = true
    var isNotifyPriceChange = true
    var isNotifyExpiredListing = true
    var isNotifyPromotions = true
    var isNotifyTips = true
    
    var favCategories: [Category] = []
    
    var json: [String: Any] {
        let favCategoryIndexes = favCategories.map { "\($0.index)" }.joined(separator: ",")
        return ["user_id": userId,
                "notif_chat_messages": isNotifyChatMessage,
                "notif_price_change": isNotifyPriceChange,
                "notif_expired_listing": isNotifyExpiredListing,
                "notif_promotions": isNotifyPromotions,
                "notif_tips": isNotifyTips,
                "fav_categories": favCategoryIndexes]
    }
    
    init() {
        
    }
    
    init(json: JSON) {
        userId = json["user_id"].intValue
        isNotifyChatMessage = json["notif_chat_messages"].boolValue
        isNotifyPriceChange = json["notif_price_change"].boolValue
        isNotifyExpiredListing = json["notif_expired_listing"].boolValue
        isNotifyPromotions = json["notif_promotions"].boolValue
        isNotifyTips = json["notif_tips"].boolValue
        
        let categoryIndexes = json["fav_categories"].stringValue.components(separatedBy: ",").map { Int($0) ?? 0 }
        favCategories = categoryIndexes.map { Category.from(index: $0) }
    }
}

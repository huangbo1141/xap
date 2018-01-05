//
//  Bulletin.swift
//  XAP
//
//  Created by Alex on 27/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Bulletin {
    var title = ""
    var content = ""
    var imagePath: URL? = nil
    var timestamp = Date()
    
    init(json: JSON) {
        title = json["title"].stringValue
        content = json["content"].stringValue
        
        let image = json["image"].stringValue
        imagePath = try? APIURL(stringLiteral: image).asPhotoURL()
        
        timestamp = Date.fromString(dateString: json["timestamp"].stringValue, format: "yyyy-MM-dd HH:mm:ss") ?? Date()
    }
}

//
//  BulletinViewModel.swift
//  XAP
//
//  Created by Alex on 27/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift

class BulletinViewModel {
    var bulletin: [Bulletin] = []
    
    func getBulletin() -> Observable<()> {
        return APIManager.default.getBulletin()
            .map {
                self.bulletin = $0
        }
    }
}

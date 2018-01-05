//
//  PostItemViewModel.swift
//  XAP
//
//  Created by Alex on 11/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift

class PostItemViewModel {
    var title = Variable<String>("")
    var description = Variable<String>("")
    var price = Variable<String>("")
    var currency = Variable<String>("CNY")
    var category = Variable<String>("")
    
    var isShippingAvailable = false
    var isFirmPrice = false
    var isAcceptableTrades = false
    
    var pictures: [UIImage?] = []
    
    init() {
        
    }
    
    func listItem() -> Observable<()>? {
        guard let user = AppContext.shared.currentUser else { return Observable.empty() }
        let photos : [UIImage] = pictures.filter { $0 != nil } as! [UIImage]
        
        
        let t = Category.all.map { $0.rawValue.localized }
        if let index = t.index(of: category.value){
            let cat = Category.all[index]
            return APIManager.default.addItem(userId: user.id,
                                              title: title.value,
                                              description: description.value,
                                              price: Float(price.value) ?? 0.0,
                                              currency: Currency(rawValue: currency.value) ?? .cny,
                                              category: cat,
                                              shippingAvailable: isShippingAvailable,
                                              firmPrice: isFirmPrice,
                                              acceptableTrades: isAcceptableTrades,
                                              photos: photos)
                .map { json in
                    _ = try? Item.createItem(in: AppContext.shared.mainContext, json: json)
                    AppContext.shared.mainContext.saveContext()
            }
        }
        return nil
        
    }
    
    func updateItem(itemId: Int) -> Observable<()>? {
        let photos : [UIImage] = pictures.filter { $0 != nil } as! [UIImage]
        let t = Category.all.map { $0.rawValue.localized }
        if let index = t.index(of: category.value){
            let cat = Category.all[index]
            return APIManager.default.updateItem(itemId: itemId,
                                                 title: title.value,
                                                 description: description.value,
                                                 price: Float(price.value) ?? 0.0,
                                                 currency: Currency(rawValue: currency.value) ?? .cny,
                                                 category: cat,
                                                 shippingAvailable: isShippingAvailable,
                                                 firmPrice: isFirmPrice,
                                                 acceptableTrades: isAcceptableTrades,
                                                 photos: photos)
                .map {
                    _ = try? Item.createItem(in: AppContext.shared.mainContext, json: $0)
                    AppContext.shared.mainContext.saveContext()
                }
        
        
        }
        return nil
    }
}

//
//  HomeViewModel.swift
//  XAP
//
//  Created by Alex on 14/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import CoreDataStack

class HomeViewModel: NSObject {
    
    let resultController: NSFetchedResultsController<Item>
    var changesCallback: ((CollectionViewBatchUpdates<Item>) -> ())?
    
    fileprivate var frcUpdateProvider: FetchedResultsUpdateProvider<Item>!
    
    var items: [Item] {
        return resultController.fetchedObjects ?? []
    }
    
   
    override init() {
        resultController = NSFetchedResultsController(fetchRequest: Item.fetchRequestForOthers(), managedObjectContext: AppContext.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        // Provider for FetchedResultController update
        frcUpdateProvider = FetchedResultsUpdateProvider(batchUpdateHandler: { [weak self] _, updates in
            guard let _self = self else { return }
            _self.changesCallback?(updates)
            debugPrint("FetchedResultsUpdateProvider")
        })
        
        resultController.delegate = frcUpdateProvider.collectionDelegate
        initialFetch()
    }
    
    func initialFetch() {
        do {
            try resultController.performFetch()
        } catch { }
    }
    
    func setFav(item: Item, isFav: Bool) -> Observable<()> {
        return ItemManager.default.setFav(item: item, isFav: isFav)
    }
    
    func getItems(offset: Int) -> Observable<()> {
        return ItemManager.default.getItems(offset: offset)
    }
    
    func setSeen(item: Item) -> Observable<()> {
        return ItemManager.default.setSeen(item: item)
    }
    
    func refresh(offset:Int) -> Observable<()> {
        return ItemManager.default.refreshItems(offset: offset)
            .map {
                self.initialFetch()
        }
    }
    
    func reportItem(item: Item, reason: ReportReason) -> Observable<()> {
        return ItemManager.default.reportItem(item: item, reason: reason)
    }
}

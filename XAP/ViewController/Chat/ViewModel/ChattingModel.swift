//
//  ChattingModel.swift
//  XAP
//
//  Created by Alex on 22/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import CoreDataStack

class ChattingModel: NSObject {
    
    var resultController: NSFetchedResultsController<Message>!
    var changesCallback: ((CollectionViewBatchUpdates<Message>) -> ())?
    
    fileprivate var frcUpdateProvider: FetchedResultsUpdateProvider<Message>!
    
    var messages: [Message] {
        return resultController.fetchedObjects ?? []
    }
    
    var itemId: Int = 0
    var userId: Int = 0
    
    private var updateSignal_ = PublishSubject<ArrayContentsUpdateSignal>()
    var updateSignal: Observable<ArrayContentsUpdateSignal> {
        return updateSignal_
    }
    
    init(itemId: Int, userId: Int) {
        super.init()
        self.itemId = itemId
        self.userId = userId
        
        resultController = NSFetchedResultsController(fetchRequest: Message.fetchRequest(itemId: itemId,
                                                                                         user1: AppContext.shared.currentUser!.id,
                                                                                         user2: userId),
                                                      managedObjectContext: AppContext.shared.mainContext,
                                                      sectionNameKeyPath: nil, cacheName: nil)
        frcUpdateProvider = FetchedResultsUpdateProvider(batchUpdateHandler: { [weak self] _, updates in
            guard let _self = self else { return }
            _self.changesCallback?(updates)
        })
        
        resultController.delegate = frcUpdateProvider.collectionDelegate
        initialFetch()
    }
    
    func initialFetch() {
        do {
            try resultController.performFetch()
        } catch { }
    }
}

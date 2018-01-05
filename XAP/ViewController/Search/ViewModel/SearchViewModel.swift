//
//  SearchViewModel.swift
//  XAP
//
//  Created by Alex on 20/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import CoreDataStack

class SearchViewModel: NSObject {
    var searchTitle: String = ""
    var distance: Distance = .mileOver10
    var minPrice: Int = 0
    var maxPrice: Int = 2000
    var publishedDate: Date = Date()
    var isShippable = false
    var isAcceptable = false
    var sortby: SortBy = .distance
    
    var category: Category? = nil
    
    let resultController: NSFetchedResultsController<Item>
    var changesCallback: ((CollectionViewBatchUpdates<Item>) -> ())?
    
    fileprivate var frcUpdateProvider: FetchedResultsUpdateProvider<Item>!
    
    var items: [Item] {
        if category == nil {
            return resultController.fetchedObjects ?? []
        }else{
            return inputItems
        }
        
    }
    
    var inputItems:[Item] = [Item]()
    
    override init() {
        resultController = NSFetchedResultsController(fetchRequest: Item.fetchRequestForOthers(), managedObjectContext: AppContext.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)

        super.init()
        
        // Provider for FetchedResultController update
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
//    var isLoading = false;
//    func initializeDB(){
//        let hud = showActivityHUD()
//        if(isLoading == 0){
//            viewModel.refresh(offset: -1).subscribe { _ in
//                self.isLoading = false
//                hud.hide(animated: true)
//                initialFetch()
//                }.addDisposableTo(_self.rx_disposeBag)
//        }
//        
//    }
    func initFilter() {
        let fetchRequest: NSFetchRequest<Item>
        if category == nil {
            fetchRequest = Item.fetchRequestForFilter(forUserId: AppContext.shared.userCredentials.userId,
                                                      title: searchTitle, distance: distance,
                                                      minPrice: minPrice, maxPrice: maxPrice,
                                                      date: publishedDate, isShippable: isShippable,
                                                      isAcceptableTrade: isAcceptable, sortBy: sortby)
        } else {
            fetchRequest = Item.fetchRequest(category: category!)
        }
        resultController.fetchRequest.predicate = fetchRequest.predicate
        resultController.fetchRequest.sortDescriptors = fetchRequest.sortDescriptors
        initialFetch()
    }
}

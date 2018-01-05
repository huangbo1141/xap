//
//  FetchedResultsUpdateProvider.swift
//  SecureTribe
//
//  Created by Alex on 28/9/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import CoreData

// MARK: - CollectionViewBatchUpdates from NSFetchedResultsController
typealias SectionChangeTuple = (changeType: NSFetchedResultsChangeType, sectionIndexes: [Int])
typealias ObjectChangeTuple = (changeType: NSFetchedResultsChangeType, indexPaths:[IndexPath])

/**
 Batch update information for collection view.
 Use `apply` function to apply update on collection view
 */
struct CollectionViewBatchUpdates<Object>{
    let sectionChanges:[SectionChangeTuple]
    let objectChanges:[ObjectChangeTuple]
    let updatedObjects:[IndexPath:Object]
    
    /**
     Applies bath updates on collection view
     - parameter to: UICollectionView to receive the update
     - parameter cellUpdater: Rather than using reloadItem at indexPath, to update cell more soomothly, proivde the closure to be executed when a item is updated
     - parameter completion: Completion Block after execution of `performBathUpdates` function
    */
    func apply<Cell>(to collectionView:UICollectionView, cellUpdater:@escaping (Cell, IndexPath, Object) -> Void, completion:((Bool) -> Void)? = nil) where Cell:UICollectionViewCell{
        collectionView.performBatchUpdates(
            {
                self.applySectionChanges(to: collectionView)
                self.applyObjectChanges(to: collectionView, cellUpdater: cellUpdater)
            },
            completion: completion)
    }
    
    private func applyObjectChanges<Cell>(to collectionView:UICollectionView, cellUpdater:(Cell, IndexPath, Object) -> Void) where Cell:UICollectionViewCell{
        for (changeType, indexPaths) in objectChanges {
            switch (changeType) {
            case .insert:
                collectionView.insertItems(at: indexPaths)
            case .delete:
                collectionView.deleteItems(at: indexPaths)
            case .update:
                if let indexPath = indexPaths.first,
                    let item = updatedObjects[indexPath],
                    let cell = collectionView.cellForItem(at: indexPath) as? Cell {
                    cellUpdater(cell, indexPath, item)
                }
            case .move:
                if let deleteIndexPath = indexPaths.first {
                    collectionView.deleteItems(at: [deleteIndexPath])
                }
                
                if let insertIndexPath = indexPaths.last {
                    collectionView.insertItems(at: [insertIndexPath])
                }
            }
        }
    }
    
    private func applySectionChanges(to collectionView:UICollectionView){
        for (changeType, sectionIndexes) in sectionChanges {
            #if DEBUG
                if case .move = changeType, sectionIndexes.count < 2 {
                    fatalError("Two section indexes (from, to) should be provided in section changes")
                } else if sectionIndexes.count == 0 {
                    fatalError("At least one section index should be provided in section changes")
                }
            #endif
            let section = IndexSet(integer: sectionIndexes[0])
            switch(changeType) {
            case .insert:
                collectionView.insertSections(section)
            case .delete:
                collectionView.deleteSections(section)
            case .move:
                collectionView.deleteSections(section)
                collectionView.insertSections(IndexSet(integer:sectionIndexes[1]))
            case .update:
                collectionView.reloadSections(section)
            }
        }
    }
}

// MARK: - Extend CollectionViewBatchUpdates to map section
extension CollectionViewBatchUpdates {
    /*
     Following to map functions `sectionMap(_:), sectionMap(_:)` should not be used both on same batch update.
     These two functions are useful when several NSFetchedResultsControllers are used on a same collection view.
     In this case we need to map section index.
     For example, when a batch update contains object changes on section 0, it can be changes on section N in UI.
     Use these two functions at your own risk.
    */
    
    /**
     Perform section number changes on object changes & updated objects
     - parameter mapper: Section getter from IndexPath
     - returns: newly mapped Batch Updates
    */
    func objectChangesSectionMap(_ mapper:(IndexPath) -> Int) -> CollectionViewBatchUpdates<Object> {
        
        // Get Section changed object changes
        let newObjectChanges = objectChanges.map { changeType, indexPaths in
            return ObjectChangeTuple(changeType: changeType, indexPaths: indexPaths.map{IndexPath(row:$0.row, section:mapper($0))})
        }
        var newUpdatedObjects = [IndexPath:Object]()
        
        for (path, item) in updatedObjects {
            newUpdatedObjects[IndexPath(row:path.row, section:mapper(path))] = item
        }
        return CollectionViewBatchUpdates(sectionChanges: sectionChanges, objectChanges: newObjectChanges, updatedObjects: newUpdatedObjects)
    }
    
    /*
     Perform section number changes (e.g. Addition specific integer or subtraction) on section changes
     - parameter mapper: Section mapper from sectionIndex
     - returns: newly mapped Batch Updates
    */
    func sectionChangesMap(_ mapper:(Int) -> Int) -> CollectionViewBatchUpdates<Object>{
        let newSectionChanges = sectionChanges.map{ changeType, indexes in
            return SectionChangeTuple(changeType:changeType, sectionIndexes:indexes.map(mapper))
        }
        return CollectionViewBatchUpdates(sectionChanges: newSectionChanges, objectChanges: objectChanges, updatedObjects: updatedObjects)
    }
    
    /*
     Map to other type.
     mapper should not fail
    */
    func map<Other>(_ mapper:(Object) -> Other?) -> CollectionViewBatchUpdates<Other>{
        var newUpdatedObjects = [IndexPath:Other]()
        for (path, object) in updatedObjects{
            newUpdatedObjects[path] = mapper(object)
        }
        return CollectionViewBatchUpdates<Other>(sectionChanges: sectionChanges, objectChanges: objectChanges, updatedObjects: newUpdatedObjects)
    }
    
    /*
     Map object changes to section changes
     Useful when a single object represents a section on the UI.
     FetchedResultsController should only have object changes and have single setion
    */
    func mapObjectChangesToSectionChanges() -> CollectionViewBatchUpdates<Object>{
        let newSectionChanges = objectChanges.map{ type, paths in
            return SectionChangeTuple(changeType:type, sectionIndexes:paths.map{$0.row})
        }
        return CollectionViewBatchUpdates<Object>(sectionChanges: newSectionChanges, objectChanges: [], updatedObjects: [:])
    }
}

// MARK: - FetchedResultsUpdateProvider
// Reason for subclassing NSObject is to make this findable in array or dictionary.
class FetchedResultsUpdateProvider<Object>:NSObject {
    init(batchUpdateHandler:@escaping (FetchedResultsUpdateProvider<Object>, CollectionViewBatchUpdates<Object>) -> Void){
        self.batchUpdateHandler = batchUpdateHandler
        super.init()
    }
    
    lazy var collectionDelegate:NSFetchedResultsControllerDelegate = {[unowned self] in
       return self.bridgedCollectionFetchedResultsDelegate()
    }()
    
    fileprivate lazy var sectionChanges = [SectionChangeTuple]()
    fileprivate lazy var objectChanges = [ObjectChangeTuple]()
    fileprivate lazy var updatedObjects = [IndexPath: Object]()
    
    private var batchUpdates:CollectionViewBatchUpdates<Object>{
        return CollectionViewBatchUpdates(sectionChanges: sectionChanges, objectChanges: objectChanges, updatedObjects: updatedObjects)
    }
    private var batchUpdateHandler:(FetchedResultsUpdateProvider<Object>, CollectionViewBatchUpdates<Object>) -> Void
    
    private func bridgedCollectionFetchedResultsDelegate() -> BridgedFetchedResultsDelegate{
        let delegate = BridgedFetchedResultsDelegate(
            willChangeContent: { [unowned self] (controller) in
                self.sectionChanges.removeAll()
                self.objectChanges.removeAll()
                self.updatedObjects.removeAll()
            },
            didChangeSection: { [unowned self] (controller, sectionInfo, sectionIndex, changeType) in
                self.sectionChanges.append((changeType, [sectionIndex]))
            },
            didChangeObject: { [unowned self] (controller, anyObject, indexPath: IndexPath?, changeType, newIndexPath: IndexPath?) in
                switch changeType {
                case .insert:
                    if let insertIndexPath = newIndexPath {
                        self.objectChanges.append((changeType, [insertIndexPath]))
                    }
                case .delete:
                    if let deleteIndexPath = indexPath {
                        self.objectChanges.append((changeType, [deleteIndexPath]))
                    }
                case .update:
                    if let indexPath = indexPath {
                        self.objectChanges.append((changeType, [indexPath]))
                        self.updatedObjects[indexPath] = anyObject as? Object
                    }
                case .move:
                    if let old = indexPath, let new = newIndexPath {
                        self.objectChanges.append((changeType, [old, new]))
                    }
                }
            },
            didChangeContent: { [unowned self] (controller) in
                self.batchUpdateHandler(self, self.batchUpdates)
            })
        return delegate
    }
}

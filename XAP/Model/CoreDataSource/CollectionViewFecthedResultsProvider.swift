//
//  CollectionViewFecthedResultsProvider.swift
//  XAP
//
//  Created by Alex on 12/10/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreData

typealias SectionCellChangeTuple = (changeType: NSFetchedResultsChangeType, indexPath: [IndexPath], isSection: Bool)

/**
 Batch update information for collection view.
 Use `apply` function to apply update on collection view
 */
class CollectionViewBatchUpdatesWithOperation<Object>{

    var blockOperations: [BlockOperation] = []
    
    let sectionCellChanges:[SectionCellChangeTuple]
    let updatedObjects:[IndexPath:Object]
    
    init(sectionCellChanges: [SectionCellChangeTuple], updatedObjects: [IndexPath: Object]) {
        self.sectionCellChanges = sectionCellChanges
        self.updatedObjects = updatedObjects
    }
    
    /**
     Applies bath updates on collection view
     - parameter to: UICollectionView to receive the update
     - parameter cellUpdater: Rather than using reloadItem at indexPath, to update cell more soomothly, proivde the closure to be executed when a item is updated
     - parameter completion: Completion Block after execution of `performBathUpdates` function
     */
    func apply<Cell>(to collectionView:UICollectionView, cellUpdater:@escaping (Cell, IndexPath, Object) -> Void, completion:((Bool) -> Void)? = nil) where Cell:UICollectionViewCell{
        
        UIView.setAnimationsEnabled(false)
        makeOperations(to: collectionView, cellUpdater: cellUpdater)
        
        collectionView.performBatchUpdates({
            for operation in self.blockOperations {
                operation.start()
            }
        }, completion: { finished in
            self.blockOperations.removeAll(keepingCapacity: false)
            UIView.setAnimationsEnabled(true)
            completion?(finished)
        })
    }
    
    deinit {
        for operation in blockOperations {
            operation.cancel()
        }
        
        blockOperations.removeAll(keepingCapacity: false)
    }
    
    private func makeOperations<Cell>(to collectionView: UICollectionView, cellUpdater: @escaping (Cell, IndexPath, Object) -> Void) where Cell:UICollectionViewCell{
        for (changeType, indexPathes, isSection) in sectionCellChanges {
            
            if isSection {
                let sections = indexPathes.map { $0.section }
                let section = IndexSet(integer: sections[0])
                
                switch changeType {
                case .insert:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.insertSections(section)
                    }))
                case .delete:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.deleteSections(section)
                    }))
                case .move:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.deleteSections(section)
                        collectionView.insertSections(IndexSet(integer: sections[1]))
                    }))
                case .update:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.reloadSections(section)
                    }))
                }
            } else {
                switch changeType {
                case .insert:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.insertItems(at: indexPathes)
                    }))
                case .delete:
                    blockOperations.append(BlockOperation(block: {
                        collectionView.deleteItems(at: indexPathes)
                    }))
                case .move:
                    blockOperations.append(BlockOperation(block: {
                        if let deleteIndexPath = indexPathes.first {
                            collectionView.deleteItems(at: [deleteIndexPath])
                        }
                        
                        if let insertIndexPath = indexPathes.last {
                            collectionView.insertItems(at: [insertIndexPath])
                        }
                    }))
                case .update:
                    if let indexPath = indexPathes.first,
                        let item = updatedObjects[indexPath],
                        let cell = collectionView.cellForItem(at: indexPath) as? Cell {
                        
                        blockOperations.append(BlockOperation(block: {
                            cellUpdater(cell, indexPath, item)
                        }))
                        
                    }
                }
            }
            
        }
    }
}

// MARK: - FetchedResultsUpdateProvider
// Reason for subclassing NSObject is to make this findable in array or dictionary.
class FetchedResultsUpdateProviderWithOperation<Object>:NSObject {
    init(batchUpdateHandler:@escaping (FetchedResultsUpdateProviderWithOperation<Object>, CollectionViewBatchUpdatesWithOperation<Object>) -> Void){
        self.batchUpdateHandler = batchUpdateHandler
        super.init()
    }
    
    lazy var collectionDelegate:NSFetchedResultsControllerDelegate = {[unowned self] in
        return self.bridgedCollectionFetchedResultsDelegate()
        }()
    
    fileprivate lazy var sectionCellChanges = [SectionCellChangeTuple]()
    fileprivate lazy var updatedObjects = [IndexPath: Object]()
    
    private var batchUpdates:CollectionViewBatchUpdatesWithOperation<Object>{
        return CollectionViewBatchUpdatesWithOperation(sectionCellChanges: sectionCellChanges, updatedObjects: updatedObjects)
    }
    private var batchUpdateHandler:(FetchedResultsUpdateProviderWithOperation<Object>, CollectionViewBatchUpdatesWithOperation<Object>) -> Void
    
    private func bridgedCollectionFetchedResultsDelegate() -> BridgedFetchedResultsDelegate{
        let delegate = BridgedFetchedResultsDelegate(
            willChangeContent: { [unowned self] (controller) in
                self.sectionCellChanges.removeAll()
                self.updatedObjects.removeAll()
            },
            didChangeSection: { [unowned self] (controller, sectionInfo, sectionIndex, changeType) in
                self.sectionCellChanges.append((changeType, [IndexPath(item: 0, section: sectionIndex)], true))
            },
            didChangeObject: { [unowned self] (controller, anyObject, indexPath: IndexPath?, changeType, newIndexPath: IndexPath?) in
                switch changeType {
                case .insert:
                    if let insertIndexPath = newIndexPath {
                        self.sectionCellChanges.append((changeType, [insertIndexPath], false))
                    }
                case .delete:
                    if let deleteIndexPath = indexPath {
                        self.sectionCellChanges.append((changeType, [deleteIndexPath], false))
                    }
                case .update:
                    if let indexPath = indexPath {
                        self.sectionCellChanges.append((changeType, [indexPath], false))
                        self.updatedObjects[indexPath] = anyObject as? Object
                    }
                case .move:
                    if let old = indexPath, let new = newIndexPath {
                        self.sectionCellChanges.append((changeType, [old, new], false))
                    }
                }
            },
            didChangeContent: { [unowned self] (controller) in
                self.batchUpdateHandler(self, self.batchUpdates)
        })
        return delegate
    }
}

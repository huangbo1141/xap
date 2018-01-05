//
//  ContentsUpdateSignal.swift
//  SecureTribe
//
//  Created by Alex on 31/3/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import CoreDataStack
import CoreData

enum ArrayContentsUpdateSignal {
    case reload //Reload
    case insert([IndexPath])
    case remove([IndexPath])
    case update([IndexPath])
    
    /**
     Default apply action to table view.
     */
    func apply(to tableView:UITableView) {
        switch self {
        case .reload:
            tableView.reloadData()
        case let .insert(ip):
            tableView.insertRows(at: ip, with: .automatic)
        case let .remove(ip):
            tableView.deleteRows(at: ip, with: .automatic)
        case let .update(ip):
            tableView.reloadRows(at: ip, with: .automatic)
        }
    }
    
    func apply(to collectionView:UICollectionView){
        switch self {
        case .reload:
            collectionView.reloadData()
        case let .insert(ip):
            collectionView.insertItems(at: ip)
        case let .remove(ip):
            collectionView.deleteItems(at: ip)
        case let .update(ip):
            collectionView.reloadItems(at: ip)
        }
    }
}

// This is exactly for iOS specific table views & collection views!
// Section change should be considered later
enum ContentsUpdateSignal<T> {
    case reload
    case beginUpdate
    case endUpdate
    case insert(object:T?, indexPath:IndexPath)
    case delete(object:T?, indexPath:IndexPath)
    case move(object:T?, fromIndexPath:IndexPath, toIndexPath:IndexPath)
    case update(object:T?, indexPath:IndexPath)
    
    case insertSections(sections:[Int])
    case deleteSections(sections:[Int])
    case reloadSections(sections:[Int])
    case moveSection(from:Int, to:Int)
    
    init(type: NSFetchedResultsChangeType, object:Any, indexPath:IndexPath?, newIndexPath:IndexPath?){
        switch type {
        case .insert:
            self = .insert(object: object as? T, indexPath: newIndexPath!)
        case .delete:
            self = .delete(object: object as? T, indexPath: indexPath!)
        case .move:
            if indexPath! == newIndexPath!  {
                self = .update(object:object as? T, indexPath: indexPath!)
            } else {
                self = .move(object:object as? T, fromIndexPath:indexPath!, toIndexPath:newIndexPath!)
            }
        case .update:
            self = .update(object:object as? T, indexPath:indexPath!)
        }
    }
    
    func map<S>(_ mapper:(T) -> S?) -> ContentsUpdateSignal<S>{
        switch self {
        case .reload:
            return .reload
        case .beginUpdate:
            return .beginUpdate
        case .endUpdate:
            return .endUpdate
        case let .insertSections(sections):
            return .insertSections(sections: sections)
        case let .deleteSections(sections):
            return .deleteSections(sections: sections)
        case let .reloadSections(sections):
            return .reloadSections(sections: sections)
        case let .moveSection(from, to):
            return .moveSection(from:from, to:to)
        case let .insert(object, indexPath):
            return .insert(object:object.flatMap{mapper($0)}, indexPath: indexPath)
        case let .delete(object, indexPath):
            return .delete(object:object.flatMap{mapper($0)}, indexPath: indexPath)
        case let .move(object, from, to):
            return .move(object:object.flatMap{mapper($0)}, fromIndexPath: from, toIndexPath: to)
        case let .update(object, indexPath):
            return .update(object:object.flatMap{mapper($0)}, indexPath:indexPath)
        }
    }
    
    /**
     Default apply action to table view.
    */
    func apply(to tableView:UITableView) {
        switch self {
        case .beginUpdate:
            tableView.beginUpdates()
        case .endUpdate:
            tableView.endUpdates()
        case .reload:
            tableView.reloadData()
        case let .insert(_, indexPath):
            tableView.insertRows(at: [indexPath], with: .automatic)
        case let .delete(_, indexPath: indexPath):
            tableView.deleteRows(at: [indexPath], with: .automatic)
        case let .update(_, indexPath):
            tableView.reloadRows(at: [indexPath], with: .automatic)
        case let .move(_, from, to):
            tableView.moveRow(at: from, to: to)
        case let .insertSections(sections):
            tableView.insertSections(IndexSet(sections), with: .automatic)
        case let .deleteSections(sections):
            tableView.deleteSections(IndexSet(sections), with: .automatic)
        case let .reloadSections(sections):
            tableView.reloadSections(IndexSet(sections), with: .automatic)
        case let .moveSection(from, to):
            tableView.moveSection(from, toSection: to)
        }
    }
    
    func apply(to collectionView:UICollectionView){
        switch self {
        case .beginUpdate:
            break
        case .endUpdate:
            break
        case .reload:
            collectionView.reloadData()
        case let .insert(_, indexPath):
            collectionView.insertItems(at: [indexPath])
            break
        case let .delete(_, indexPath: indexPath):
            collectionView.deleteItems(at: [indexPath])
        case let .update(_, indexPath):
            collectionView.reloadItems(at: [indexPath])
        case let .move(_, from, to):
            collectionView.moveItem(at: from, to: to)
        case let .insertSections(sections):
            collectionView.insertSections(IndexSet(sections))
        case let .deleteSections(sections):
            collectionView.deleteSections(IndexSet(sections))
        case let .reloadSections(sections):
            collectionView.reloadSections(IndexSet(sections))
        case let .moveSection(from, to):
            collectionView.moveSection(from, toSection: to)
        }
    }
}

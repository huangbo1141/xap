//
//  ProfileViewModel.swift
//  XAP
//
//  Created by Alex on 12/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import CoreDataStack

class ProfileViewModel: NSObject {
    var userName = Variable<String>("")
    var firstName = Variable<String>("")
    var lastName = Variable<String>("")
    var birthday = Variable<String>("")
    var address = Variable<String>("")
    var gender: Gender = .male
    var email = Variable<String>("")
    
    var profileImageUrl: URL? = nil
    var profileImage: UIImage? = nil
    
    var userSetting: Settings!
    
    let sellingItemsResultController: NSFetchedResultsController<Item>
    let soldItemsResultController: NSFetchedResultsController<Item>
    
    var sellingItemsChangesCallback: ((CollectionViewBatchUpdates<Item>) -> ())?
    var soldItemsChangesCallback: ((CollectionViewBatchUpdates<Item>) -> ())?
    
    fileprivate var sellingItemFrcProvider: FetchedResultsUpdateProvider<Item>!
    fileprivate var soldItemFrcProvider: FetchedResultsUpdateProvider<Item>!
    
    var sellingItems: [Item] {
        return sellingItemsResultController.fetchedObjects ?? []
    }
    
    var soldItems: [Item] {
        return soldItemsResultController.fetchedObjects ?? []
    }
    
    var user: User!
    
    init(user: User) {
        sellingItemsResultController = NSFetchedResultsController(fetchRequest: Item.fetchRequestSelling(userId: user.id), managedObjectContext: AppContext.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        soldItemsResultController = NSFetchedResultsController(fetchRequest: Item.fetchRequestSold(userId: user.id), managedObjectContext: AppContext.shared.mainContext, sectionNameKeyPath: nil, cacheName: nil)
        
        super.init()
        
        self.user = user
        userName.value = user.userName
        firstName.value = user.firstName
        lastName.value = user.lastName
        birthday.value = user.birthday.toDateString(format: "yyyy-MM-dd")!
        gender = user.gender
        email.value = user.email
        address.value = user.address
        
        profileImage = user.avatarImage
        profileImageUrl = try? APIURL(stringLiteral: user.profileImage).asPhotoURL()
        
        userSetting = AppContext.shared.currentUserSetting
        
        sellingItemFrcProvider = FetchedResultsUpdateProvider(batchUpdateHandler: { [weak self] _, updates in
            guard let _self = self else { return }
            _self.sellingItemsChangesCallback?(updates)
        })
        
        soldItemFrcProvider = FetchedResultsUpdateProvider(batchUpdateHandler: { [weak self] _, updates in
            guard let _self = self else { return }
            _self.soldItemsChangesCallback?(updates)
        })
        
        sellingItemsResultController.delegate = sellingItemFrcProvider.collectionDelegate
        soldItemsResultController.delegate = soldItemFrcProvider.collectionDelegate
        
        initialFetch()
    }
    
    func initialFetch() {
        do {
            try sellingItemsResultController.performFetch()
            try soldItemsResultController.performFetch()
        } catch { }
    }
    
    func updateProfile() -> Observable<()> {
//        guard let user = AppContext.shared.currentUser else { return Observable.empty() }
        user.firstName_ = firstName.value
        user.lastName_ = lastName.value
        user.birthday_ = birthday.value
        user.address_ = address.value
        user.gender_ = gender.rawValue as NSNumber
        user.email_ = email.value
        
        return APIManager.default.updateProfile(user: user, profileImage: profileImage)
            .map {
                guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: $0) else { return }
                AppContext.shared.currentUser = user
        }
    }
    
    func updateProfileSettings() -> Observable<()> {
//        guard let user = AppContext.shared.currentUser else { return Observable.empty() }
        return APIManager.default.updateProfileSettings(userId: user.id,
                                                        settings: userSetting)
            .map {
                AppContext.shared.currentUserSetting = $0
        }
    }
    
    func verifyFacebook(facebook: String) -> Observable<()> {
        return APIManager.default.verifyFacebook(userId: AppContext.shared.currentUser!.id, facebook: facebook)
            .map {
                AppContext.shared.currentUser!.facebook_ = facebook
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func verifyGoogle(google: String) -> Observable<()> {
        return APIManager.default.verifyGoogle(userId: AppContext.shared.currentUser!.id, google: google)
            .map {
                AppContext.shared.currentUser!.google_ = google
                AppContext.shared.mainContext.saveContext()
        }
    }
    
    func verifyEmail() -> Observable<()> {
        return APIManager.default.verifyEmail(userId: AppContext.shared.currentUser!.id)
    }
    
    func signOut() -> Observable<()> {
        AppContext.shared.currentUser = nil
        AppContext.shared.userCredentials.delete()
        
        _ = try? Message.removeAllInContext(AppContext.shared.mainContext)
        
        return ItemManager.default.refreshItems(offset:0)
    }
}

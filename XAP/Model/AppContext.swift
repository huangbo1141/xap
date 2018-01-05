//
//  AppContext.swift
//  HitchJob
//
//  Created by Alex on 18/5/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import SwiftLocation
import CoreLocation
import CoreData

class AppContext: NSObject {
    static var shared = AppContext()
    
    static var keyValueStore = UserDefaults.standard
    static var searchItems = [Item]()
    
    var isReachable = true
    
    var currentUser: User? = nil
    
    public static var itemRefreshed_search = true
    
    var currentUserID: Int = 0
    var currentUserSetting = Settings()
    
    var userCredentials : UserCredentials = {
        var credentials = UserCredentials(kvStore: AppContext.keyValueStore)
        credentials.load()
        return credentials
    }()
    
    var currentLocation: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    let persistentContainer = NSPersistentContainer(name: "XAP")
    var mainContext: NSManagedObjectContext!
    
    var timer: Timer? = nil
    
    var notifData: [String: Any]? = nil
    
    override init() {
        super.init()
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            self.mainContext = self.persistentContainer.viewContext
        }
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
}

extension AppContext {
    func startUpdatingMessages() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(timerFired), userInfo: nil, repeats: true)
    }
    
    func timerFired() {
        guard userCredentials.userId > 0 else { return }
        APIManager.default.getChats(userId: userCredentials.userId, lastMessageDate: userCredentials.lastMessageTimeStamp)
            .map { chatsJSON in
                for json in chatsJSON {
                    _ = try? Message.createMessage(in: self.mainContext, json: json)
                }
                
                // Is first load of messages
                if !AppContext.shared.userCredentials.isNotFirstLoadMessage {
                    Message.markAllRead(context: AppContext.shared.mainContext)
                    AppContext.shared.userCredentials.isNotFirstLoadMessage = true
                    AppContext.shared.userCredentials.save()
                }
                
                if chatsJSON.count > 0 {
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateMessageCount"), object: nil)
                }
        }.subscribe().addDisposableTo(rx_disposeBag)
    }
}

//
//  LandingViewModel.swift
//  XAP
//
//  Created by Alex on 12/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift

class LandingViewModel {
    init() {
        
    }
    
    func signIn(email: String, password: String) -> Observable<()> {
        return APIManager.default.login(email: email, password: password)
            .flatMap { json -> Observable<()> in
                guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { return Observable.error(APIError.login) }
                
                AppContext.shared.currentUser = user
                
                AppContext.shared.userCredentials.userId = user.id
                AppContext.shared.userCredentials.email = email
                AppContext.shared.userCredentials.password = password
                AppContext.shared.userCredentials.save()
                
                return APIManager.default.setDeviceToken(userId: user.id, token: AppContext.shared.userCredentials.deviceToken)
            }.flatMap {_ in 
                return ItemManager.default.refreshItems(offset:0)
//                return ItemManager.default.getUserItems()
        }
    }
    
    func signUp(username: String, email: String, password: String,lat:String,lng:String) -> Observable<()> {
        return APIManager.default.signup(username: username, email: email, password: password,lat:lat,lng:lng)
            .flatMap { json -> Observable<()> in
                if let id = json["id"].intValue as? Int {
                    AppContext.shared.currentUserID = id
                    return APIManager.default.setDeviceToken(userId: id, token: AppContext.shared.userCredentials.deviceToken)
                }else { return Observable.error(APIError.login) }
                
//                guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { return Observable.error(APIError.login) }
                
//                AppContext.shared.currentUser = user
//
//                AppContext.shared.userCredentials.userId = user.id
//                AppContext.shared.userCredentials.email = email
//                AppContext.shared.userCredentials.password = password
//                AppContext.shared.userCredentials.save()
//
//                return APIManager.default.setDeviceToken(userId: user.id, token: AppContext.shared.userCredentials.deviceToken)
                
            }.flatMap {_ in 
                return ItemManager.default.refreshItems(offset: 0)
//                return ItemManager.default.getUserItems()
        }
    }
    
    func signinFacebook(email: String, name: String, firstName: String, lastName: String) -> Observable<()> {
        return APIManager.default.signInWithFacebook(email: email, userName: name, firstName: firstName, lastName: lastName)
            .flatMap{ json -> Observable<()> in
                guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { return Observable.error(APIError.login) }
                
                AppContext.shared.currentUser = user
                
                AppContext.shared.userCredentials.userId = user.id
                AppContext.shared.userCredentials.save()
                
                AppContext.shared.startUpdatingMessages()
                
                return APIManager.default.setDeviceToken(userId: user.id, token: AppContext.shared.userCredentials.deviceToken)
            }.flatMap {_ in 
                return ItemManager.default.refreshItems(offset: 0)
        }
    }
    
    func signinGoogle(email: String, name: String, firstName: String, lastName: String) -> Observable<()> {
        return APIManager.default.signInWithGoogle(email: email, userName: name, firstName: firstName, lastName: lastName)
            .flatMap{ json -> Observable<()> in
                guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { return Observable.error(APIError.login) }
                
                AppContext.shared.currentUser = user
                
                AppContext.shared.userCredentials.userId = user.id
                AppContext.shared.userCredentials.save()
                
                AppContext.shared.startUpdatingMessages()
                
                return APIManager.default.setDeviceToken(userId: user.id, token: AppContext.shared.userCredentials.deviceToken)
            }.flatMap {_ in 
                return ItemManager.default.refreshItems(offset: 0)
        }
    }
}

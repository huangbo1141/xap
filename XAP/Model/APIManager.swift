//
//  MainViewModel.swift
//  XAP
//
//  Created by Alex on 6/2/2017.
//
//

import Foundation
import RxSwift
import Alamofire
import SwiftyJSON
import RxAlamofire

protocol BaseAPIManager{
    var manager:Alamofire.SessionManager { get }
}

extension BaseAPIManager {
    func post(_ url:APIURL, parameters params:[String:Any], encoding:ParameterEncoding = URLEncoding.default) -> Observable<JSON>{
        return manager.rx.responseData(.post, url, parameters: params, encoding: encoding)
            //        return manager.rx.responseData(.post, url)
            .flatMap { response -> Observable<(HTTPURLResponse, Data)> in
                
                #if isTesting
                    guard url.path != APIURL.getChats.path else { return Observable.just(response) }
                    let logText = JSON(data: response.1).description
                    return self.manager.rx.responseData(.post, APIURL.log_error, parameters: ["api": url.path, "params": params.description, "result": logText], encoding: encoding)
                        .map { _ in response }
                #else
                    return Observable.just(response)
                #endif
                
            }
            .map{
//                Log.info(String(data: $1, encoding: .utf8))
                return try! JSON(data: $1)
        }
    }
    
    func post(url: String, parameters params:[String:Any], encoding:ParameterEncoding = URLEncoding.default) -> Observable<JSON>{
        
        let _url = URL(string: url)
        return manager.rx.responseData(.post, _url!, parameters: params, encoding: encoding)
            .map{
                return try! JSON(data: $1)
        }
    }
    
    func get(_ url:APIURL, parameters params:[String:Any], encoding:ParameterEncoding = URLEncoding.default) -> Observable<JSON>{
        return manager.rx.responseData(.get, url, parameters: params, encoding: encoding)
            .map{ try! JSON(data: $1) }
    }
    
    func uploadImage(_ url: APIURL, parameters params:[String: Any], encoding:ParameterEncoding = URLEncoding.default, image: UIImage) -> Observable<JSON> {
        let uploadData = UIImagePNGRepresentation(image)!
        return manager.upload(uploadData, to: url).rx.responseData().map { return try! JSON(data: $1) }
    }
    
    func uploadMultipart(_ url: APIURL, parameters params:[String: Any], method: HTTPMethod = .post, encoding: ParameterEncoding = URLEncoding.default, image: UIImage? = nil, imageName: String = "photo", fileName: String = "photo_file.jpg") -> Observable<JSON> {
        let ob = Observable<JSON>.create { observer -> Disposable in
            self.manager.upload(
                multipartFormData: { multipartFormData in
                    if let _image = image {
                        multipartFormData.append(UIImageJPEGRepresentation(_image, 0.5)!, withName: imageName, fileName: fileName, mimeType: "image/jpeg")
                    }
                    for (key, value) in params {
                        multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
                    }
            },
                to: url,
                method: method,
                encodingCompletion: { result in
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { responseData in
                            observer.onNextAndCompleted(JSON(responseData.data!))
                        })
                    case let .failure(error):
                        observer.onError(error)
                    }
            })
            
            return Disposables.create()
        }
        return ob
    }
}

// MARK: - Invalid Session Handler
extension ObservableType where E == APIResponse {
    /**
     Hook api response and if error code for invalid session Id found, filter the signal and show invalid session screen.
     Also this will automatically sign out user.
     */
    func handleAPIResponse() -> Observable<JSON> {
        return
            filter{response in
                guard let err = APIError(response:response) else {
                    return true
                }
                
                print("Error code from response : \(err)")
                
                throw err
                }.map{
                    return $0.json!
        }
    }
}

// MARK: - Invalid Session Handler
extension ObservableType where E == JSON {
    /**
     Hook api response and if error code for invalid session Id found, filter the signal and show invalid session screen.
     Also this will automatically sign out user.
     */
    func handleAPIResponse() -> Observable<JSON> {
        return
            filter{json in
                let response = APIResponse(json: json)
                guard let err = APIError(response:response) else {
                    return true
                }
                
                print("Error code from response : \(err)")
                
                throw err
                }.map{
                    return $0
        }
    }
}

class APIManager:BaseAPIManager {
    let manager:SessionManager
    
    static let `default` : APIManager = {
//        let configuration = URLSessionConfiguration.default
//        configuration.httpAdditionalHeaders = SessionManager.defaultHTTPHeaders
//        configuration.timeoutIntervalForRequest = 3600
//        let sessionManager = SessionManager(configuration: configuration)
//        return APIManager(manager: sessionManager)
        return APIManager(manager:SessionManager.default)
    }()
    
    init(manager:SessionManager){
        self.manager = manager
    }
    
    func login(email: String, password: String) -> Observable<JSON> {
        return post(.login, parameters: ["email": email, "password": password])
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    
    func signup(username: String, email: String, password: String,lat:String,lng:String) -> Observable<JSON> {
        // need to pass lat lng
        
        return post(.signup, parameters: ["username": username, "email": email, "password": password,"lat": lat,"lng": lng])
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func signInWithFacebook(email: String, userName: String, firstName: String, lastName: String) -> Observable<JSON> {
        let params = ["facebook": email, "user_name": userName, "first_name": firstName, "last_name": lastName]
        return post(.signInWithFacebook, parameters: params)
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func signInWithGoogle(email: String, userName: String, firstName: String, lastName: String) -> Observable<JSON> {
        let params = ["google": email, "user_name": userName, "first_name": firstName, "last_name": lastName]
        return post(.signInWithGoogle, parameters: params)
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func userInfo(id: Int) -> Observable<JSON> {
        return post(.getUserInfo, parameters: ["id": id])
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func updateProfile(user: User, profileImage: UIImage?) -> Observable<JSON> {
        return uploadMultipart(.updateProfile, parameters: user.json, method: .post, image: profileImage, imageName: "photo")
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func getProfileSettings(userId: Int) -> Observable<Settings> {
        return post(.getProfileSettings, parameters: ["user_id": userId])
            .handleAPIResponse()
            .map {
                return Settings(json: $0["data"])
        }
    }
    
    func updateProfileSettings(userId: Int, settings: Settings) -> Observable<Settings> {
        var params = settings.json
        params["user_id"] = userId
        
        return post(.updateProfileSettings, parameters: params)
            .handleAPIResponse()
            .map {
                return Settings(json: $0["data"])
        }
    }
    
    func addItem(userId: Int, title: String, description: String, price: Float, currency: Currency, category: Category, shippingAvailable: Bool, firmPrice: Bool, acceptableTrades: Bool, photos: [UIImage] = []) -> Observable<JSON> {
        let params : [String: Any] = ["user_id": userId,
                                      "title": title,
                                      "description": description,
                                      "category": category.index,
                                      "price": price,
                                      "currency": currency.index,
                                      "shipping_available": shippingAvailable.int,
                                      "firm_price": firmPrice.int,
                                      "acceptable_trades": acceptableTrades.int,
                                      "latitude": Float(AppContext.shared.currentLocation.latitude),
                                      "longitude": Float(AppContext.shared.currentLocation.longitude)]
        let ob = Observable<JSON>.create { observer -> Disposable in
            self.manager.upload(
                multipartFormData: { multipartFormData in
                    for index in 0..<photos.count {
                        multipartFormData.append(UIImageJPEGRepresentation(photos[index], 0.5)!, withName: "pic\(index + 1)", fileName: "\(title)\(index + 1).jpg", mimeType: "image/jpeg")
                    }
                    
                    for (key, value) in params {
                        multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
                    }
            },
                to: APIURL.addItem,
                method: .post,
                encodingCompletion: { result in
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { responseData in
                            observer.onNextAndCompleted(JSON(responseData.data!))
                        })
                    case let .failure(error):
                        observer.onError(error)
                    }
            })
            
            return Disposables.create()
        }
        
        return ob.handleAPIResponse().map {
            return $0["data"]
        }
    }
    
    func updateItem(itemId: Int, title: String, description: String, price: Float, currency: Currency, category: Category, shippingAvailable: Bool, firmPrice: Bool, acceptableTrades: Bool, photos: [UIImage] = []) -> Observable<JSON> {
        let params : [String: Any] = ["item_id": itemId,
                                      "title": title,
                                      "description": description,
                                      "category": category.index,
                                      "price": price,
                                      "currency": currency.index,
                                      "shipping_available": shippingAvailable.int,
                                      "firm_price": firmPrice.int,
                                      "acceptable_trades": acceptableTrades.int]
        let ob = Observable<JSON>.create { observer -> Disposable in
            self.manager.upload(
                multipartFormData: { multipartFormData in
                    for index in 0..<photos.count {
                        multipartFormData.append(UIImageJPEGRepresentation(photos[index], 0.5)!, withName: "pic\(index + 1)", fileName: "\(title)\(index + 1).jpg", mimeType: "image/jpeg")
                    }
                    
                    for (key, value) in params {
                        multipartFormData.append(String(describing: value).data(using: .utf8)!, withName: key)
                    }
            },
                to: APIURL.updateItem,
                method: .post,
                encodingCompletion: { result in
                    switch result {
                    case .success(let upload, _, _):
                        upload.responseData(completionHandler: { responseData in
                            observer.onNextAndCompleted(JSON(responseData.data!))
                        })
                    case let .failure(error):
                        observer.onError(error)
                    }
            })
            
            return Disposables.create()
        }
        
        return ob.handleAPIResponse().map {
            return $0["data"]
        }
    }
    
    func getItem(id: Int) -> Observable<JSON> {
        return post(.getItem, parameters: ["id": id])
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func getItems(userId: Int, latitude: Float, longitude: Float, offset: Int) -> Observable<[JSON]> {
        let params = ["user_id": userId, "latitude": latitude, "longitude": longitude, "offset": offset] as [String : Any]
        return post(.getItems, parameters: params)
            .handleAPIResponse()
            .map {
                return $0["data"].arrayValue
        }
    }
    
    func getItemsForCategory(userId: Int, latitude: Float, longitude: Float, offset: Int, category:Category) -> Observable<[JSON]> {
        let params = ["user_id": userId, "latitude": latitude, "longitude": longitude, "offset": offset,"category_id":category.index] as [String : Any]
        return post(.getItems, parameters: params)
            .handleAPIResponse()
            .map {
                return $0["data"].arrayValue
        }
    }
    
    func getUserItems(userId: Int) -> Observable<[JSON]> {
        return post(.getUserItems, parameters: ["user_id": userId])
            .handleAPIResponse()
            .map {
                return $0["data"].arrayValue
        }
    }
    
    func setFav(userId: Int, itemId: Int, isFavourite: Bool) -> Observable<()> {
        let params: [String: Any] = ["user_id": userId, "item_id": itemId, "fav": isFavourite]
        return post(.setFav, parameters: params)
            .handleAPIResponse()
            .map{ _ in
                
            }
    }
    
    func getFavourites(ofItem itemId: Int) -> Observable<[JSON]> {
        return post(.getFavOfItem, parameters: ["item_id": itemId])
            .handleAPIResponse()
            .map { response in
                let results = response["data"].arrayValue
                return results.map { $0["user"] }
        }
    }
    
    func getFavourites(ofUser userId: Int) -> Observable<[JSON]> {
        return post(.getFavOfUser, parameters: ["user_id": userId])
            .handleAPIResponse()
            .map { response in
                let results = response["data"].arrayValue
                return results.map { $0["item"] }
        }
    }
    
    func setSeen(itemId: Int) -> Observable<()> {
        return post(.setSeen, parameters: ["item_id": itemId])
            .handleAPIResponse()
            .map { _ in
                
        }
    }
    
    func reportItem(reporterId: Int, itemId: Int, reason: ReportReason) -> Observable<()> {
        return post(.reportItem, parameters: ["reporter": reporterId,
                                              "reported_id": itemId,
                                              "type": reason.rawValue,
                                              "reason": reason.string])
            .handleAPIResponse()
            .map { _ in
        }
    }
    
    func deleteItem(itemId: Int) -> Observable<()> {
        return post(.deleteItem, parameters: ["item_id": itemId])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func sellItem(itemId: Int) -> Observable<()> {
        return post(.sellItem, parameters: ["item_id": itemId])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func reserveItem(itemId: Int, isReserved: Bool) -> Observable<()> {
        return post(.reserveItem, parameters: ["item_id": itemId, "is_reserved": isReserved])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func verifyFacebook(userId: Int, facebook: String) -> Observable<()> {
        return post(.verifyFacebook, parameters: ["user_id": userId, "facebook": facebook])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func verifyGoogle(userId: Int, google: String) -> Observable<()> {
        return post(.verifyGoogle, parameters: ["user_id": userId, "google": google])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func verifyEmail(userId: Int) -> Observable<()> {
        return post(.verifyEmail, parameters: ["user_id": userId])
            .handleAPIResponse()
            .flatMap{ json -> Observable<JSON> in
                let data = json["data"].dictionaryValue
                let toEmail = data["to_email"]?.stringValue ?? ""
                let body = data["body"]?.stringValue ?? ""
                
                let params = ["crendentials": "@$?76ctv",
                              "from": "xap676@gmail.com",
                              "to": toEmail,
                              "body": body,
                              "subject": "Email Verification",
                              "from_name": "XAP Support"]
                return self.post(url: "http://82.223.19.247/webservice/include/test.php", parameters: params)
            }
            .map { json in
                if json["result"].intValue == 0 {
                    let error = APIError.unknown(json["details"].string)
                    throw error
                }
        }
    }
    
    func sendChat(itemId: Int, fromId: Int, toId: Int, message: String) -> Observable<JSON> {
        let params : [String: Any] = ["item_id": itemId, "from_user_id": fromId, "to_user_id": toId, "message": message]
        return post(.sendChat, parameters: params)
            .handleAPIResponse()
            .map {
                return $0["data"]
        }
    }
    
    func getChats(userId: Int, lastMessageDate: String = "0000-00-00 00:00:00") -> Observable<[JSON]> {
        return post(.getChats, parameters: ["user_id": userId,
                                            "last_date": lastMessageDate])
            .handleAPIResponse()
            .map {
                return $0["data"].arrayValue
        }
    }
    
    /**
     Remove Messages
     - Parameter ids: String of messages Id, joined with ','
     */
    func deleteChats(ids: String) -> Observable<()> {
        return post(.deleteChats, parameters: ["ids": ids])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func setDeviceToken(userId: Int, token: String) -> Observable<()> {
        return post(.setDeviceToken, parameters: ["user_id": userId, "token": token])
            .handleAPIResponse()
            .map { _ in }
    }
    
    func getBulletin() -> Observable<[Bulletin]> {
        return post(.getBulletin, parameters: [:])
            .handleAPIResponse()
            .map { json -> [Bulletin] in
                let result = json["data"].arrayValue.map { Bulletin(json: $0) }
                return result
        }
    }
    
    func forgetPassword(email: String) -> Observable<()> {
        return post(.forgetPassword, parameters: ["email": email])
            .handleAPIResponse()
            .flatMap{ json -> Observable<JSON> in
                let data = json["data"].dictionaryValue
                let toEmail = data["to_email"]?.stringValue ?? ""
                let body = data["body"]?.stringValue ?? ""
                
                let params = ["crendentials": "@$?76ctv",
                              "from": "xap676@gmail.com",
                              "to": toEmail,
                              "body": body,
                              "subject": "Recover Password",
                              "from_name": "XAP Support"]
                return self.post(url: "http://82.223.19.247/webservice/include/test.php", parameters: params)
            }
            .map { json in
                if json["result"].intValue == 0 {
                    let error = APIError.unknown(json["details"].string)
                    throw error
                }
        }
    }
}

struct APIResponse {
    var status = ""
    var code = -1
    var message = ""
    var json: JSON? = nil

    init() {
        
    }
    
    init(json: JSON) {
        status = json["stat"].stringValue
        code = json["code"].intValue
        message = json["message"].stringValue
        self.json = json
    }
}

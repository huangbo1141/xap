//
//  APIURL.swift
//  JockeysTickers
//
//  Created by Alex on 6/2/2017.
//
//

import Foundation
import Alamofire

struct APIURL {
    let path:String
    
    static let endPoint = "http://82.223.19.247/xap/api"
    static let dataPoint = "http://82.223.19.247/xap"
//    static let endPoint = "http://192.168.0.198/xap/api"
//    static let dataPoint = "http://192.168.0.198/xap"
    
    // Add log api
    static let log_error: APIURL = "/log_error.php"
    
    // Define all apis here...
    static let login: APIURL = "/user_login.php"
    static let signup: APIURL = "/user_signup.php"
    static let getUserInfo: APIURL = "/get_user_info.php"
    static let addItem: APIURL = "/add_item.php"
    static let updateProfile: APIURL = "/update_user.php"
    static let updateProfileSettings: APIURL = "/set_profile_settings.php"
    static let getProfileSettings: APIURL = "/get_profile_settings.php"
    static let getItem: APIURL = "/get_item_info.php"
    static let getItems: APIURL = "/get_items.php"
    static let getUserItems: APIURL = "/get_user_items.php"
    static let getFavOfItem: APIURL = "/get_favs_of_item.php"
    static let getFavOfUser: APIURL = "/get_favs_of_user.php"
    static let setFav: APIURL = "/set_fav.php"
    static let setSeen: APIURL = "/set_seen_item.php"
    static let reportItem: APIURL = "/add_report.php"
    static let deleteItem: APIURL = "/delete_item.php"
    static let sellItem: APIURL = "/sell_item.php"
    static let reserveItem: APIURL = "/reserve_item.php"
    static let updateItem: APIURL = "/update_item.php"
    
    static let signInWithFacebook: APIURL = "/signin_facebook.php"
    static let signInWithGoogle: APIURL = "/signin_google.php"
    static let verifyFacebook: APIURL = "/verify_facebook.php"
    static let verifyGoogle: APIURL = "/verify_google.php"
    static let verifyEmail: APIURL = "/verify_email.php"
    
    static let sendChat: APIURL = "/add_chat.php"
    static let getChats: APIURL = "/get_chat.php"
    static let deleteChats: APIURL = "/delete_chat.php"
    
    static let setDeviceToken: APIURL = "/set_token.php"
    
    static let getBulletin: APIURL = "/get_bulletin.php"
    static let forgetPassword: APIURL = "/forget_password.php"
    
}

// MARK: - Extend APIURL to conform URLConvertible
extension APIURL:URLConvertible{
    func asURL() throws -> URL {
        #if IS_DEBUG
            return URL(string: APIURL.endPoint + path + "?XDEBUG_SESSION_START=PHPSTORM")!
        #endif
        return URL(string: APIURL.endPoint + path)!
    }
    
    func asPhotoURL() throws -> URL {
        return URL(string: APIURL.dataPoint + path)!
    }
    
    static func photoURL(path: String) throws -> URL {
        return URL(string: APIURL.dataPoint + path)!
    }
}

extension APIURL: ExpressibleByStringLiteral {
    init(stringLiteral value: String) {
        path = value
    }
    
    init(unicodeScalarLiteral value: String) {
        path = value
    }
    
    init(extendedGraphemeClusterLiteral value: String) {
        path = value
    }
}

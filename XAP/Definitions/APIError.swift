//
//  APIError.swift
//  FreeMan
//
//  Created by Alex on 23/6/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation

let kAPIErrorSuccess = 0

enum APIError {
    case unknown(String?)
    case login
    case duplicateEmail
    case duplicateUsername
}

extension APIError: Error { }

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unknown(let msg):
            return msg
        case .login:
            return "Please login".localized
        case .duplicateEmail:
            return "The email address has already been registered!".localized
        case .duplicateUsername:
            return "The username has already been registered!".localized
        }
    }
    
    init?(response: APIResponse) {
        switch response.code {
        case kAPIErrorSuccess:
            return nil
        case 111:
            self = .duplicateEmail
        case 113:
            self = .duplicateUsername
        default:
            self = .unknown(response.message)
        }
    }
}

extension Error {
    func errorMessage(message: String) -> String {
        var msg = self.localizedDescription
        if msg == "" {
            msg = message
        }
        return msg
    }
}

//
//  PermissionScope+Rx.swift
//  XAP
//
//  Created by Alex on 2/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import PermissionScope
import RxSwift

// MARK: - Rx Extension for PermissionScope
extension PermissionScope {
    /**
     rx_extension for requesting single permission
    */
    static func rx_request(for permission:Permission, message:String) -> Observable<PermissionResult>{
        let singlePScope = PermissionScope()
        singlePScope.addPermission(permission, message: message)
        singlePScope.headerLabel.text = "XAP"
        singlePScope.bodyLabel.text = "We need following permission to continue"
        //singlePScope.viewControllerForAlerts = self
        return Observable.create{ observer in
            singlePScope.show(
                { _, results in
                    observer.onNext(results.first!)
                    observer.onCompleted()
                },
                cancelled: {results in
                    observer.onNext(results.first!)
                    observer.onCompleted()
                }
            )
            return Disposables.create{
                singlePScope.hide()
            }
        }
    }
    
    /**
     rx_extension for requesting multiple permissions
    */
    static func rx_request(for permissions:[Permission], messages:[String]) -> Observable<[PermissionResult]> {
        precondition(permissions.count == messages.count && permissions.count > 0)
        let multiScope = PermissionScope()
        Zip2Sequence(_sequence1: permissions, _sequence2: messages).forEach {
            multiScope.addPermission($0, message: $1)
        }
        multiScope.headerLabel.text = "XAP"
        multiScope.bodyLabel.text = "We need following permissions to continue"
        
        return Observable.create{ observer in
            multiScope.show(
                { _, results in
                    observer.onNext(results)
                    observer.onCompleted()
                },
                cancelled: {results in
                    observer.onNext(results)
                    observer.onCompleted()
                }
            )
            return Disposables.create{
                multiScope.hide()
            }
        }
    }
}

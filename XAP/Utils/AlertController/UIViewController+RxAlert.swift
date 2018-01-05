//
//  UIViewController+RxAlert.swift
//  Cattivo VIA
//
//  Created by Alex on 14/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

// MARK: - Rx support for alert & action sheet
extension Reactive where Base:UIViewController {
    /// Alert
    func alert(
        title:String? = nil,
        message:String,
        cancelTitle ct:String? = nil,
        destructiveTitle dt:String? = nil,
        otherTitles:[String] = []) -> Observable<AlertControllerResult> {
        return Observable.create{observer -> Disposable in
            let alert = UIAlertController.alert(title: title, message: message, cancelTitle: ct, destructiveTitle: dt, otherTitles: otherTitles, callback: {
                observer.onNext($0)
                observer.onCompleted()
            })
            self.base.present(alert, animated: true)
            return Disposables.create{
                alert.dismiss(animated: true)
            }
        }
    }
    
    /// ActionSheet
    func actionSheet(
        title:String? = nil,
        cancelTitle ct:String? = nil,
        destructiveTitle dt:String? = nil,
        otherTitles:[String] = [],
        popoverConfig:PopoverConfig) -> Observable<AlertControllerResult>{
        return Observable.create{ observer -> Disposable in
            let alert = UIAlertController.actionSheet(title: title, cancelTitle: ct, destructiveTitle: dt, otherTitles: otherTitles, popoverConfig: popoverConfig, callback: {
                observer.onNext($0)
                observer.onCompleted()
            })
            self.base.present(alert, animated: true)
            return Disposables.create{
                alert.dismiss(animated: true)
            }
        }
    }
    
    // Text Input
    func textInput(
        title:String? = nil,
        message:String? = nil,
        configurator:((UITextField) -> Void)? = nil,
        okTitle:String = "OK",
        cancelTitle:String = "Cancel",
        validation:@escaping (String) -> Bool = {!$0.trimmingCharacters(in: .whitespaces).isEmpty}) -> Observable<String?>{
        return Observable.create{ observer -> Disposable in
            let alert = UIAlertController.textInput(title: title, message: message, configurator:configurator, okTitle: okTitle, cancelTitle: cancelTitle, validation: validation, callback: {
                observer.onNext($0)
                observer.onCompleted()
            })
            self.base.present(alert, animated: true)
            return Disposables.create{
                alert.dismiss(animated: true)
            }
        }
    }
}

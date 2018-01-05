//
//  MediaPickerController+Rx.swift
//  XAP
//
//  Created by Alex on 29/4/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - Rx Extension for MediaPickerController
extension MediaPickerController {
    class func rx_pick(from viewController:UIViewController, type:MediaPickerType, maxVideoDuration:TimeInterval) -> Observable<[PickedMedia]> {
        return type.rx_requestPermission()
            .flatMapLatest{authorized -> Observable<[PickedMedia]> in
                guard authorized else  { return Observable.just([]) }
                return Observable<[PickedMedia]>
                    .create{observer -> Disposable in
                        let controller = MediaPickerController(baseViewController: viewController, type: type, maxVideoDuration: maxVideoDuration)
                        
                        controller.pickMedia{result in
                            observer.onNext(result)
                            observer.onCompleted()
                            controller.freePickers()
                        }
                        return Disposables.create()
                }
        }
    }
}

//
//  PermissionUtil.swift
//  AutoCorner
//
//  Created by Alex on 13/4/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import Foundation
import AVFoundation
import AssetsLibrary
import Photos
import RxSwift
import RxCocoa

enum AppPermission:String {
    case Microphone = "Microphone"
    case Photos = "Photo Library"
    case Camera = "Camera"
}

enum AppPermissionStatus {
    case unknown
    case denied
    case restricted
    case granted
}

extension AppPermission : CustomStringConvertible{
    // Title
    var description:String {
        return self.rawValue
    }
    
    var notGrantedMessage:String{
        switch self {
        case .Microphone:
            return "You have no access to microphone and no audio will be recorded. Please enable access to Microphone in Settings."
        case .Photos:
            return "You are not granted access to photo library. Please enable access to Photos in Settings."
        case .Camera:
            return "You are not granted access to Camera. Please enable access to Camera in Settings."
        }
    }
}

// MARK: - Camera & Microphone access
extension AVAuthorizationStatus {
    func toPermissionStatus() -> AppPermissionStatus {
        switch self {
        case .authorized:
            return .granted
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .unknown
        }
    }
}

// MARK: - Photo Access
extension PHAuthorizationStatus {
    func toPermissionStatus() -> AppPermissionStatus {
        switch self {
        case .authorized:
            return .granted
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .unknown
        }
    }
}

// MARK: - Microphone
extension AVAudioSessionRecordPermission {
    func toPermissionStatus() -> AppPermissionStatus {
        if contains(.granted) {
            return .granted
        } else if contains(.denied) {
            return .denied
        } else {
            return .unknown
        }
    }
}

// MARK: - Determine current status
extension AppPermission {
    var authorizationStatus:AppPermissionStatus {
        switch self {
        case .Camera:
            return AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo).toPermissionStatus()
        case .Microphone:
            return AVAudioSession.sharedInstance().recordPermission().toPermissionStatus()
        case .Photos:
            return PHPhotoLibrary.authorizationStatus().toPermissionStatus()
        }
    }
}

// MARK: - Request access
extension AppPermission {
    // Request Access for any cases.
    func requestAccess() -> Observable<AppPermissionStatus>{
        let status = authorizationStatus
        guard case .unknown = status else { return Observable.just(status) }
        return Observable<AppPermissionStatus>.create{ observer -> Disposable in
            switch self {
            case .Camera:
                AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){ _ in
                    observer.onNext(self.authorizationStatus)
                    observer.onCompleted()
                }
            case .Microphone:
                AVAudioSession.sharedInstance().requestRecordPermission{ _ in
                    observer.onNext(self.authorizationStatus)
                    observer.onCompleted()
                }
            case .Photos:
                PHPhotoLibrary.requestAuthorization{
                    observer.onNext($0.toPermissionStatus())
                    observer.onCompleted()
                }
            }
            return Disposables.create()
        }
    }
    
    // Request Access with showing Denied Message
    // Try Request access
    func requestAccessAlertWhenNotGranted(_ topViewController:UIViewController) -> Observable<AppPermissionStatus> {
        return requestAccess()
            .observeOn(MainScheduler.instance)
            .flatMapLatest{ status -> Observable<AppPermissionStatus> in
                // If already granted, just return that status.
                if case .granted = status  {
                    return Observable.just(status)
                }
                // More one step to show alert that access is denied. and provide option.
                return topViewController
                    .rx.alert(title: self.description, message: self.notGrantedMessage, cancelTitle: "Cancel", otherTitles: ["Settings"])
                    .map{ style, _ -> AppPermissionStatus in
                        // If user tapped Settings, then open settings app.
                        if case .default = style {
                            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                        }
                        return status
                }
        }
    }
}

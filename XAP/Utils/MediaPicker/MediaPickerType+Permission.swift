//
//  MediaPickerType+Permission.swift
//  XAP
//
//  Created by Alex on 2/6/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import PermissionScope
import RxSwift

extension MediaPickerType {
    // Request permission for specific media picker type and returns true or false if can continue.
    func rx_requestPermission() -> Observable<Bool>{
        switch self {
        case .cameraRollImage, .cameraRoll, .cameraRollMovie:
            return PermissionScope.rx_request(for: PhotosPermission(), message: "Enable access to Photos").map{$0.status == .authorized}
        case .takePhoto:
            return PermissionScope.rx_request(for: CameraPermission(), message: "Enable access to Camera").map{$0.status == .authorized}
        case .captureMovie:
            return PermissionScope.rx_request(for: [CameraPermission(), MicrophonePermission()], messages: ["Enable access to Camera", "Enable access to Microphone"]).map{
                // Here user only might give access to cameras, not microphone.
                $0[0].status == .authorized
            }
        case .iCloudDrive:
            return Observable.just(true)
        }
    }
}

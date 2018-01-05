//
//  MediaPickerController.swift
//  PickerTest
//
//  Created by Alex on 28/4/2016.
//  Copyright © 2016 StockNumSystems. All rights reserved.
//

import Foundation
import UIKit
import MobileCoreServices
import SCImagePicker
import Photos
import RxSwift
import RxCocoa
import Cartography

enum MediaPickerType {
    case cameraRoll
    case takePhoto
    case captureMovie
    case iCloudDrive
    case cameraRollImage    //Added two more types :)
    case cameraRollMovie
}

typealias MediaPickerControllerCallback = ([PickedMedia]) -> ()
typealias MediaPickerControllerCancelCallback = (Void) -> ()

class MediaPickerController : NSObject {
    fileprivate var imagePicker:PortraitImagePickerController?
    fileprivate var docPicker:UIDocumentPickerViewController?
    fileprivate var cameraRollPicker:SCImagePickerController?
    
    fileprivate var type:MediaPickerType = .cameraRoll
    fileprivate var callback: MediaPickerControllerCallback?
    fileprivate var cancelCallback: MediaPickerControllerCancelCallback?
    
    fileprivate let disposeBag = DisposeBag()
    
    // The viewcontroller which presented picker (weak pointer)
    fileprivate weak var baseViewController:UIViewController?
    
    let maxVideoDuration:TimeInterval
    
    var allowsMultipleSelection = false
    var kMaximumAllowedMultiFilesCount = 1
    
    var maxiumDurationReachHandler : (() -> ())?
    
    /**
     Start pick media from view controller
    */
    init (baseViewController:UIViewController, type:MediaPickerType, maxVideoDuration:TimeInterval, cancelCallback: MediaPickerControllerCancelCallback? = nil, callback: MediaPickerControllerCallback? = nil){
        self.baseViewController  = baseViewController
        self.type = type
        self.maxVideoDuration = maxVideoDuration
        
        self.cancelCallback = cancelCallback
        
        guard let _callback = callback else { return }
        self.callback = _callback
    }

    func pickMedia(_ callback:MediaPickerControllerCallback?){
        guard let baseViewController = baseViewController else { return }
        self.callback = callback
        switch type {
        case .iCloudDrive:
            pickUsingiCloud(from: baseViewController)
        case .cameraRoll, .cameraRollImage, .cameraRollMovie:
            pickUsingSCImagePicker(from: baseViewController)
        default:
            pickUsingImagePickerController(from: baseViewController, type: type)
        }
    }
    
    fileprivate func pickUsingiCloud(from viewController:UIViewController){
        docPicker = UIDocumentPickerViewController(documentTypes: [kUTTypeData as String], in: .import).then{
            $0.delegate = self
            viewController.present($0, animated: true, completion: nil)
        }
    }
    
    /**
     Take Picture, Take Video
     */
    fileprivate func pickUsingImagePickerController(from viewController:UIViewController, type:MediaPickerType){
        guard type != .iCloudDrive && type != .cameraRoll else { return }
        imagePicker = PortraitImagePickerController().then{
            $0.delegate = self
            switch type {
            case .takePhoto:
                $0.sourceType = .camera
                $0.mediaTypes = [kUTTypeImage as String]
    
            case .captureMovie:
                $0.sourceType = .camera
                $0.mediaTypes = [kUTTypeMovie as String]
                
                // Capture with high quality
                $0.videoQuality = UIImagePickerControllerQualityType.typeHigh
            default: break
            }
            
            let picker = $0
            if type == .captureMovie || type == .takePhoto {
                $0.showsCameraControls = false  // Hide iOS default buttons
//                $0.cameraOverlayView = CaptureOverlayView(frame: viewController.view.bounds)
                $0.cameraOverlayView = CaptureOverlayView(frame: ext.windowFrame.portrait)
                    .then{
                        $0.maximumVideoDurationInSeconds = maxVideoDuration
                        $0.delegate = self
                        $0.imagePickerController = picker
                }
            }
            viewController.present(picker, animated: true, completion: nil)
        }
    }
    
    /**
     Camera Roll
    */
    fileprivate func pickUsingSCImagePicker(from viewController:UIViewController){
        // Camera roll
        let picker = SCImagePickerController().then{
            $0.allowsMultipleSelection = allowsMultipleSelection
            $0.maximumNumberOfSelection = kMaximumAllowedMultiFilesCount
            if $0.allowsMultipleSelection {
                $0.prompt = "Pick up to \(kMaximumAllowedMultiFilesCount) photos"
            }
            if type == .cameraRollImage {
                $0.mediaType = .image
            } else if type == .cameraRollMovie {
                $0.mediaType = .video
            }
        }
        picker.pickerDelegate = self
        cameraRollPicker = picker
        viewController.present(picker, animated: true, completion: nil)
    }
 
    /**
     This is actually tricky to keep the strong reference of this media picker controller on callback. (for Rx)
    */
    func freePickers(){
        imagePicker = nil
        docPicker = nil
        callback = nil
        cameraRollPicker = nil
    }
}

extension MediaPickerController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            print(picker.mediaTypes)
            (picker.cameraOverlayView as? CaptureOverlayView)?.isCapturingVideo = false
            if picker.sourceType == .camera,
                picker.mediaTypes.contains(kUTTypeMovie as String),
                let captureOverlayView = picker.cameraOverlayView as? CaptureOverlayView,
                captureOverlayView.maximumDurationReached {
                maximumDurationReached(withURL: url, upgradeHandler: { [weak self] in
                    self?.maxiumDurationReachHandler?()
                })
                return
            } else {
                callback?([.file(url)])
            }
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            callback?([.photo(image)])
        }
    }
    
    // When cancel tapped in imagePickerController
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // This block will be called when User tapped Cancel button in Camera Roll View Controller.
        
        // ImagePicker doesn't dismiss itself when it's delegate is available and should be manually dismissed.
        baseViewController?.dismiss(animated: true){
            self.callback?([])
            self.callback = nil
        }
    }
    
    /**
     To be called when maximumDurationReached video captured.
    */
    func maximumDurationReached(withURL url:URL, upgradeHandler: ((Void) -> ())? = nil){
        guard let picker = imagePicker else { return }
        
    }

    /**
     To be called when need to display user is not allowed to select duration overflow video
    */
    func showMaximumDurationExceeded(upgradeHandler: ((Void) -> ())? = nil){
        guard let picker = (imagePicker ?? cameraRollPicker) else { return }
        
    }
}

extension MediaPickerController:CaptureOverlayViewDelegate {
    func captureOverlayViewDidPressCancel(_ overlayView: UIView) {
        if cancelCallback != nil {
            cancelCallback!()
            return
        }
        
        // Need to dismiss all here.
        baseViewController?.dismiss(animated: true){
            self.callback?([])
            self.callback = nil
        }
    }
}

extension MediaPickerController : UIDocumentPickerDelegate {
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        // Do not directly dimiss here.
        // Document Picker is automatically dismissed by iOS SDK.
        callback?([])
    }
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        guard let baseViewController = self.baseViewController else {
            return
        }
        callback?([.file(url)])
    }
}

// MARK: - CameraRollPickerDelegate
extension MediaPickerController : SCImagePickerControllerDelegate{
    func scImagePickerControllerDidCancel(_ imagePickerController: SCImagePickerController) {
        baseViewController?.dismiss(animated: true){
            self.callback?([])
        }
    }
    
    func scImagePickerController(_ imagePickerController: SCImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        guard assets.count > 0 else {
            baseViewController?.dismiss(animated: true){
                self.callback?([])
            }
            return
        }
        
        callback?(assets.map{ .asset($0) })
    }
    
    func scImagePickerController(_ imagePickerController: SCImagePickerController, shouldSelectAsset asset: PHAsset) -> Bool {
        if maxVideoDuration > 0, case .video = asset.mediaType, asset.duration > maxVideoDuration {
            // Should show some kind of message.
            showMaximumDurationExceeded(upgradeHandler: {
                
            })
            return false
        }
        
        return true
    }
}

/**
 Created by Alexis
 - Getting media pickers
 */
extension MediaPickerController {
    var imagePickerController : UIImagePickerController {
        get {
            if imagePicker != nil {
                return imagePicker!
            }
            
            imagePicker = PortraitImagePickerController().then{
                $0.delegate = self
                switch type {
                case .takePhoto:
                    $0.sourceType = .camera
                    $0.mediaTypes = [kUTTypeImage as String]
                    
                case .captureMovie:
                    $0.sourceType = .camera
                    $0.mediaTypes = [kUTTypeMovie as String]
                    
                    // Capture with high quality
                    $0.videoQuality = UIImagePickerControllerQualityType.typeHigh
                default: break
                }
                
                let picker = $0
                if type == .captureMovie || type == .takePhoto {
                    $0.showsCameraControls = false  // Hide iOS default buttons
//                    $0.cameraOverlayView = CaptureOverlayView(frame: (baseViewController?.view.bounds)!)
                    $0.cameraOverlayView = CaptureOverlayView(frame: ext.windowFrame.portrait)
                        .then{
                            $0.maximumVideoDurationInSeconds = maxVideoDuration
                            $0.delegate = self
                            $0.imagePickerController = picker
                    }
                }
            }
            
            return imagePicker!
        }
    }
}

class PortraitImagePickerController : UIImagePickerController {
    override var shouldAutorotate: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

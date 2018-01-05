//
//  ImagePickerControllerWrapper.swift
//  XAP
//
//  Created by Alex on 16/11/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import MobileCoreServices
import RxSwift
import RxCocoa
import SCImagePicker
import Photos

// Simple UIImagePickerController wrapper
struct ImagePickerControllerConfig {
    // define source types, video/image quality, allowsEditing, when allow editing, use rsk image cropper, ...
    // Define some default configs so let coders code happily.
    var allowsEditing: Bool
    var videoQuality: UIImagePickerControllerQualityType
    var initialCameraDevice: UIImagePickerControllerCameraDevice
    var usesCustomOverlayForPhoto:Bool          // Flag indicating if uses custom overlay for photo capture
    var usesCustomOverlayForMovie:Bool          // Flag indicating if uses custom overlay for movie capture
    var maxVideoDuration:TimeInterval           // Max time interval duration
    var usesCustomImageEditor:Bool              // Flag if use custom image editr like rsk image cropper.
    var cropImageSize: CGSize? = nil            // Size of cropped image. If nill, square mode
    
    static var `default`:ImagePickerControllerConfig{
        return ImagePickerControllerConfig(
            allowsEditing: false,
            videoQuality: .typeMedium,
            initialCameraDevice: .rear,
            usesCustomOverlayForPhoto: false,
            usesCustomOverlayForMovie: false,
            maxVideoDuration: 0,
            usesCustomImageEditor: false,
            cropImageSize: nil
        )
    }
    
    
    // Some static configs.
    static var profileImage:ImagePickerControllerConfig {
        var result = `default`
        result.initialCameraDevice = .front
        result.allowsEditing = true
        result.usesCustomImageEditor = true
        return result
    }
    
    // For chat file
    static var chatFile:ImagePickerControllerConfig {
        var result = `default`
        result.maxVideoDuration = 60    // Set maximum video duration to 60
        return result
    }
    
    // Scan QR Code
    static var qrParse:ImagePickerControllerConfig {
        var result = `default`
        result.allowsEditing = true
        result.usesCustomImageEditor = true
        return result
    }
}


class SimpleImagePickerController:NSObject {
    fileprivate var uiPicker:UIImagePickerController?
    fileprivate var callback:((PickedMedia?) -> Void)?
    fileprivate var type: MediaPickerType = .cameraRoll
    fileprivate var scPicker:SCImagePickerController?
    
    var config: ImagePickerControllerConfig
    
    init (config: ImagePickerControllerConfig, targetImageSize: CGSize? = nil) {
        self.config = config
        self.config.cropImageSize = targetImageSize
    }
    
    func pick(from vc:UIViewController, type:MediaPickerType,  callback: @escaping (PickedMedia?) -> Void) {
        
        // Check if should display scPicker.
        // Should display
        if !config.allowsEditing,
            (type == .cameraRoll || type == .cameraRollMovie || type == .cameraRollImage) {
            let picker = SCImagePickerController()
            picker.maximumNumberOfSelection = 1
            picker.showsNumberOfSelectedAssets = false
            picker.pickerDelegate = self
            
            if case .cameraRollMovie = type {
                picker.mediaType = .video
            } else if case .cameraRollImage = type {
                picker.mediaType = .image
            } else {
                picker.mediaType = .any
            }
            
            self.scPicker = picker
            self.type = type
            self.callback = callback
            
            vc.present(picker, animated:true)
            return
        }
        
        
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = config.allowsEditing
        
        // When use custom image editor, set allows editing flag to false
        if config.usesCustomImageEditor {
            // Disable editing on actual UIImagePickerController instance
            picker.allowsEditing = false
        }
        
        self.type = type
        
        picker.videoQuality = config.videoQuality
        
        switch type{
        case .cameraRoll:
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        case .takePhoto:
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeImage as String]
            picker.cameraDevice = config.initialCameraDevice
        case .captureMovie:
            picker.sourceType = .camera
            picker.mediaTypes = [kUTTypeMovie as String]
            picker.cameraDevice = config.initialCameraDevice
        case .cameraRollImage:
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeImage as String]
        case .cameraRollMovie:
            picker.sourceType = .photoLibrary
            picker.mediaTypes = [kUTTypeMovie as String]
        default:
            break
        }
        
        
        if (type == .takePhoto && config.usesCustomOverlayForPhoto) ||
            (type == .captureMovie && config.usesCustomOverlayForMovie) {
            picker.showsCameraControls = false
            picker.cameraOverlayView = CaptureOverlayView(frame: ext.windowFrame.portrait).then{
                $0.delegate = self
                $0.imagePickerController = picker
            }
        }
        
        self.uiPicker = picker
        self.callback = callback    // Assign callback
        
        vc.present(picker, animated: true)
    }
    
    fileprivate func clean(){
        callback = nil
        uiPicker = nil
        scPicker = nil
    }
    
    fileprivate func cancelAndDismiss(){
        uiPicker?.presentingViewController?.dismiss(animated: true){
            self.callback?(nil)
            self.clean()
        }
        
        scPicker?.presentingViewController?.dismiss(animated: true){
            self.callback?(nil)
            self.clean()
        }
    }
}

extension SimpleImagePickerController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        cancelAndDismiss()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage,
            config.allowsEditing, config.usesCustomImageEditor {
            let rskCropVC = RSKImageCropViewController(image: image)
            rskCropVC.delegate = self
            
            if config.cropImageSize == nil {
                rskCropVC.cropMode = .square
            } else {
                rskCropVC.dataSource = self
                rskCropVC.cropMode = .custom
            }
            
            rskCropVC.maskLayerStrokeColor = .white
            
            picker.pushViewController(rskCropVC, animated: true)
            return
        }
        
        uiPicker?.presentingViewController?.dismiss(animated: true){
            if let url = info[UIImagePickerControllerMediaURL] as? URL {
                self.callback?(.file(url))
            } else if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.callback?(.photo(image))
            } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.callback?(.photo(image))
            } else {
                self.callback?(nil)
            }
            self.clean()
        }
    }
}

extension SimpleImagePickerController: CaptureOverlayViewDelegate {
    func captureOverlayViewDidPressCancel(_ overlayView: UIView) {
        cancelAndDismiss()
    }
}

extension SimpleImagePickerController: RSKImageCropViewControllerDelegate, RSKImageCropViewControllerDataSource {
    func imageCropViewControllerDidCancelCrop(_ controller: RSKImageCropViewController) {
        // Check if config's mode is capture photo, if capture photo and not using custom controls, should call callback and fail.
        if type == .takePhoto && !config.usesCustomOverlayForPhoto {
            // There will be a bug if only pop out rsk view controller, should completely dismiss viewcontroller.
            cancelAndDismiss()
            return
        }
        
        // In other case, pop the crop view controller and give next chance to pick image.
        _ = uiPicker?.popViewController(animated: true)
    }
    
    func imageCropViewController(_ controller: RSKImageCropViewController, didCropImage croppedImage: UIImage, usingCropRect cropRect: CGRect) {
        uiPicker?.presentingViewController?.dismiss(animated: true){
            self.callback?(.photo(croppedImage))
            self.clean()
        }
    }
    
    func imageCropViewControllerCustomMaskRect(_ controller: RSKImageCropViewController) -> CGRect {
        let viewWidth = controller.view.frame.width
        let viewHeight = controller.view.frame.height
        
        var maskSize = config.cropImageSize!
        if maskSize.width > maskSize.height {
            let ratio = CGFloat(maskSize.height) / CGFloat(maskSize.width)
            maskSize.width = viewWidth - 50
            maskSize.height = maskSize.width * ratio
        } else {
            let ratio = CGFloat(maskSize.width) / CGFloat(maskSize.height)
            maskSize.height = viewWidth - 50
            maskSize.width = maskSize.height * ratio
        }
        
        let maskRect = CGRect(x: (viewWidth - maskSize.width) * 0.5,
                              y: (viewHeight - maskSize.height) * 0.5,
                              width: maskSize.width,
                              height: maskSize.height)
        return maskRect
    }
    
    func imageCropViewControllerCustomMovementRect(_ controller: RSKImageCropViewController) -> CGRect {
        return controller.maskRect
    }
    
    func imageCropViewControllerCustomMaskPath(_ controller: RSKImageCropViewController) -> UIBezierPath {
        let rect = controller.maskRect
        return UIBezierPath(rect: rect)
    }
}

extension SimpleImagePickerController: SCImagePickerControllerDelegate {
    func scImagePickerController(_ imagePickerController: SCImagePickerController, shouldSelectAsset asset: PHAsset) -> Bool {
        if config.maxVideoDuration > 0, case .video = asset.mediaType, asset.duration > config.maxVideoDuration {
            return false
        }
        return true
    }
    
    func scImagePickerController(_ imagePickerController: SCImagePickerController, didFinishPickingAssets assets: [PHAsset]) {
        guard let asset = assets.first else { return }
        scPicker?.presentingViewController?.dismiss(animated: true){
            self.callback?(.asset(asset))
            self.clean()
        }
    }
    
    func scImagePickerControllerDidCancel(_ imagePickerController: SCImagePickerController) {
        self.cancelAndDismiss()
    }
}

// MARK: - Rx Extension
extension Reactive where Base: SimpleImagePickerController {
    func pick(from vc:UIViewController, type: MediaPickerType) -> Observable<PickedMedia?>{
        return type
            .rx_requestPermission()
            .flatMapLatest{ authorized -> Observable<PickedMedia?> in
                guard authorized else { return Observable.just(nil) }
                return Observable.create{ observer in
                    self.base.pick(from: vc, type: type, callback: observer.onNextAndCompleted)
                    return Disposables.create {
                        self.base.cancelAndDismiss()
                    }
                }
        }
    }
}



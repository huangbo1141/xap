//
//  VideoCaptureViewController.swift
//  XAP
//
//  Created by Alex on 16/5/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import AVFoundation

// MARK: - AVPreview view.
class AVPreviewView: UIView {
    
    override class var layerClass:Swift.AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var session:AVCaptureSession{
        get {
            let previewLayer = layer as! AVCaptureVideoPreviewLayer
            return previewLayer.session
        }
        
        set {
            let previewLayer = layer as! AVCaptureVideoPreviewLayer
            previewLayer.session = newValue
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        }
    }
}

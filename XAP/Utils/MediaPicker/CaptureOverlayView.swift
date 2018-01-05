//
//  PhotoCaptureOverlayView.swift
//  PickerTest
//
//  Created by Alex on 28/4/2016.
//  Copyright © 2016 StockNumSystems. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion

fileprivate let kNibName = "CaptureOverlayView"

protocol CaptureOverlayViewDelegate:class {
    func captureOverlayViewDidPressCancel(_ overlayView:UIView)
}

class CaptureOverlayView:UIView {
    fileprivate var view:UIView!
    
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var captureButtonBorderView: UIView!
    
    @IBOutlet weak var flashIndicatorButton: UIButton!
    @IBOutlet weak var flashAutoButton: UIButton!
    @IBOutlet weak var flashOffButton: UIButton!
    @IBOutlet weak var flashOnButton: UIButton!
    @IBOutlet weak var cameraToggleButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var timeLabel: UILabel!
    
    fileprivate var accelerationMonitoringStarted = false
    var motionManager:CMMotionManager?
    
    weak var delegate:CaptureOverlayViewDelegate?
    
    // ImagePickerController property.
    weak var imagePickerController:UIImagePickerController? {
        didSet {
            // When image picker controller is set, start motion updates
            guard let imagePickerController = self.imagePickerController else { return }
            if motionManager == nil {
                initializeMotionManager()
            }
            
            // Set capture button image background.
            if case .photo = imagePickerController.cameraCaptureMode {
                // Set white background
                captureButton.setBackgroundImage(.colored(.white), for: [.normal])
            } else {
                captureButton.setBackgroundImage(.colored(.red), for: [.normal])
            }
            
            updateButtonsStatus()
            // Update Capture Button
            updateCaptureButton()
        }
    }
    
    // MARK: - Capture properties
    fileprivate var captureStartedTime:Date?  //Capture started time.
    fileprivate var captureTimer:Timer?       //Capture Timer for displaying current time on the label.
    var maximumVideoDurationInSeconds = TimeInterval(0)
    fileprivate(set) var maximumDurationReached = false  // Will set to true when captured video is stopped due to
    
    var isCapturingVideo:Bool = false { // Flag for capturing video.
        didSet {
            if oldValue != isCapturingVideo {
                updateCaptureButton()   // UpdateCaptureButton
            }
            
            timeLabel.isHidden = !isCapturingVideo
            
            if isCapturingVideo {
                if oldValue != isCapturingVideo {
                    // reset flag again.
                    maximumDurationReached = false
                }
                //Start Timer
                captureStartedTime = Date()
                updateCaptureTime()
                captureTimer = Timer.scheduledTimer(
                    timeInterval: 0.3,
                    target: self,
                    selector: #selector(captureTimerFired(_:)),
                    userInfo: nil,
                    repeats: true)
                timeLabel.fadeIn()
                
                
            } else {
                captureTimer?.invalidate()
                captureStartedTime = nil
                timeLabel.fadeOut()
            }
            
            // Update Buttons Status also
            updateButtonsStatus()
        }
    }
    
    // Initially orientation is portrait
    fileprivate var currentOrientation = UIInterfaceOrientation.portrait {
        didSet {
            guard oldValue != currentOrientation else { return }
            
            UIView.animate(withDuration: 0.25){
                //Animate with duration
                self.controlsNeed2BeRotated.forEach{
                    $0.transform = self.currentOrientation.controlsRotationTransform
                }
                
                //Timeframe label
            }
        }
    }
    
    fileprivate var controlsNeed2BeRotated:[UIView] {
        return [flashIndicatorButton, flashAutoButton, flashOffButton, flashOnButton, cameraToggleButton, timeLabel, cancelButton]
    }
        
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    // Initialize UI.
    func xibSetup(){
        view = loadViewFromNib().then{
            $0.frame = bounds
            $0.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            addSubview($0)
            
            // Setup UI elements
            captureButton.makeOvalBorder(color:.clear, borderWidth: 0)
            captureButtonBorderView.makeOvalBorder(color:.white, borderWidth: 3.0)
            captureButton.setBackgroundImage(.colored(.white), for: [.normal])
            
            [flashAutoButton!, flashOffButton!, flashOnButton!].forEach{
                $0.setTitleColor(.white, for: [.normal])
                $0.setTitleColor(.yellow, for: [.selected])
                $0.setTitleColor(.gray, for: [.disabled])
            }
            
            timeLabel.then{
                $0.isHidden = true
                $0.alpha = 0.0
            }
        }
    }
    
    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kNibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    
    deinit {
        // Stop updates
        motionManager?.stopAccelerometerUpdates()
    }
}

// MARK: - Control Events, status updates
extension CaptureOverlayView{
    @IBAction func cameraToggleButtonTapped(_ sender: AnyObject) {
        guard let picker = imagePickerController else { return }
        switch picker.cameraDevice{
        case .front:
            if UIImagePickerController.isCameraDeviceAvailable(.rear){
                picker.cameraDevice = .rear
            }
        case .rear:
            if UIImagePickerController.isCameraDeviceAvailable(.front){
                picker.cameraDevice = .front
            }
        }
        updateButtonsStatus()
    }
    
    @IBAction func captureButtonTapped(_ sender: AnyObject) {
        guard let imagePickerController = imagePickerController else { return }
        if case .photo = imagePickerController.cameraCaptureMode {
            imagePickerController.takePicture()
        } else {
            if isCapturingVideo {
                captureTimer?.invalidate()  // clear timer first
                imagePickerController.stopVideoCapture()
                isCapturingVideo = false
            } else {
                isCapturingVideo = imagePickerController.startVideoCapture()
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        delegate?.captureOverlayViewDidPressCancel(self)
    }
    
    @IBAction func flashAutoButtonTapped(_ sender: AnyObject) {
        flashAutoButton.isSelected = true
        flashOnButton.isSelected = false
        flashOffButton.isSelected = false
        imagePickerController?.cameraFlashMode = .auto
    }
    
    @IBAction func flashOnButtonTapped(_ sender: AnyObject) {
        flashAutoButton.isSelected = false
        flashOnButton.isSelected = true
        flashOffButton.isSelected = false
        imagePickerController?.cameraFlashMode = .on
    }
    
    @IBAction func flashOffButtonTapped(_ sender: AnyObject) {
        flashAutoButton.isSelected = false
        flashOnButton.isSelected = false
        flashOffButton.isSelected = true
        imagePickerController?.cameraFlashMode = .off
    }
    
    func updateButtonsStatus(){
        guard let picker = imagePickerController else {
            return
        }
        
        // When Capturing video disable all buttons
        if isCapturingVideo {
            [flashAutoButton, flashOnButton, flashOffButton, cancelButton, cameraToggleButton].forEach{
                $0.isEnabled = false
            }
            return
        } else {
            // Enable camera toggle button & Cancel button
            cameraToggleButton.isEnabled = true
            cancelButton.isEnabled = true
        }
        
        if UIImagePickerController.isFlashAvailable(for: picker.cameraDevice){
            [flashAutoButton, flashOnButton, flashOffButton].forEach{
                $0.isEnabled = true
            }
            switch picker.cameraFlashMode {
            case .auto:
                flashAutoButton.isSelected = true
                flashOnButton.isSelected = false
                flashOffButton.isSelected = false
            case .on:
                flashAutoButton.isSelected = false
                flashOnButton.isSelected = true
                flashOffButton.isSelected = false
            case .off:
                flashAutoButton.isSelected = false
                flashOnButton.isSelected = false
                flashOffButton.isSelected = true
            }
        } else {
            [flashAutoButton, flashOnButton, flashOffButton].forEach{
                $0?.isEnabled = false
                $0?.isSelected = false
            }
        }
    }
    
    // MARK: - Capture Button
    func updateCaptureButton(){
        if isCapturingVideo {
            captureButton.layer.mask = CAShapeLayer().then{
                let maskBounds = captureButton.bounds.insetBy(dx: 10, dy: 10)
                let path = UIBezierPath(roundedRect: maskBounds, byRoundingCorners: .allCorners, cornerRadii:CGSize(width: 10, height: 10))
                $0.path = path.cgPath
            }
        } else {
            // Clear mask
            captureButton.layer.mask = nil
        }
    }
    
    // MARK: - Capture Time
    func captureTimerFired(_ sender:AnyObject){
        // Update Capture Time
        updateCaptureTime()
    }
    
    // Update current capture time.
    func updateCaptureTime(){
        guard let captureStartedTime = captureStartedTime , isCapturingVideo else { return }
        let interval = Date().timeIntervalSince(captureStartedTime)
        
        if maximumVideoDurationInSeconds > 0 {
            timeLabel.text = interval.mmssFormat() + "/" + maximumVideoDurationInSeconds.mmssFormat()
        } else {
            timeLabel.text = interval.mmssFormat()
        }
        
        // Check if maximum duration reached.
        if maximumVideoDurationInSeconds > 0, interval > maximumVideoDurationInSeconds {
            // set flag to true
            maximumDurationReached = true
            
            // Stop video capture
            captureTimer?.invalidate()
            imagePickerController?.stopVideoCapture()
            isCapturingVideo = false
        }
    }
    
    /// Called when video capture is finished with url
    func videoCaptured(at url:URL){
        
    }
}

// MARK: - MotionManager Initialization
extension CaptureOverlayView {
    func initializeMotionManager(){
        motionManager = CMMotionManager().then{
            $0.accelerometerUpdateInterval = 0.1
        }
        
        motionManager?.startAccelerometerUpdates(to: OperationQueue.main){[weak self] data, _ in
            guard let data = data, let orientation = data.acceleration.toInterfaceOrientation() /*where orientation != .PortraitUpsideDown*/ else { return }
            self?.currentOrientation = orientation
        }
    }
}


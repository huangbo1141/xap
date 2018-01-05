//
//  VideoCaptureViewController.swift
//  XAP
//
//  Created by Alex on 16/5/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit
import AVFoundation

enum AVCamSetupResult:Int {
    case success = 0
    case cameraNotAuthorized
    case sessionConfigurationFailed
}

enum CameraError:Error {
    case noCaptureDevice
    case unableToResume
}

// Extends AVCaptureTorchMode
extension AVCaptureTorchMode{
    var boolValue:Bool{
        return self == .on
    }
    
    init(boolValue:Bool){
        self = boolValue ? .on : .off
    }
}

fileprivate var sessionRunningContext = 0

class VideoCaptureViewController: UIViewController {
    
    // MARK: - Camera Capture.
    @IBOutlet weak var previewView : AVPreviewView!
    var previewLayer:AVCaptureVideoPreviewLayer{
        return previewView.layer as! AVCaptureVideoPreviewLayer
    }
    
    var session:AVCaptureSession!
    var sessionRunning:Bool = false
    var videoDeviceInput:AVCaptureDeviceInput?
    var setupResult:AVCamSetupResult = .success
    
    // MARK: - Session Management
    var sessionQueue:DispatchQueue = DispatchQueue(label: "com.justtwodudes.XAP.CaptureSession")
    
    var isCaptureSessionRunning = false // session.isRunning observer
    
    var isSessionResumable = false // This is false when session is running or stopped and not resumable.
    
    /// Check camera is unavailable.
    var isCameraUnavailable = false
    
    /// Check if device's torch is on.
    var isTorchOn = false
    
    // MARK: - ViewController LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        initCameraSession()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sessionQueue.async{
            self.startCameraSession()
        }
        
        // In Sub Class it should say not authorized or something when setup result is not succeed.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async{
            self.stopCameraSession()
        }
    }
    
}

// MARK: - Handle Rotation
extension VideoCaptureViewController{
    // Also, shouldAutoRotate and supportedInterfaceOrientations functions should be declared in sub view controllers.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Note that the app delegate controls the device orientation notifications required to use the device orientation
        let deviceOrientation = UIDevice.current.orientation
        if deviceOrientation.isPortrait || deviceOrientation.isLandscape {
            previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: deviceOrientation.rawValue)!
        }
    }
}

// MARK: - Extension Init Camera Session
extension VideoCaptureViewController {
    func initCameraSession(){
        // This is the most first step : Create a Capture Session
        session = AVCaptureSession()
        
        //Setup the preview view
        previewView.session = session
        
        // Check video authorization status. Video access is required and audio access is optional.
        // If audio access is denied, audio is not recorded during movie recording.
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        switch authStatus{
        case .authorized:
            //The user has previously granted access to the camera.
            break
        case .notDetermined:
            // The user has not yet been presented with the option to grant video access.
            // We suspend the session queue to delay session setup until the access request has completed to avoid
            // asking the user for audio access if video access is denied.
            // Note that audio access will be implicitly requested when we create an AVCaptureDeviceInput for audio during session setup.
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo){
                granted in
                if !granted {
                    self.setupResult = .cameraNotAuthorized
                }
                self.sessionQueue.resume()
            }
        default:
            // The user has previously denied access.
            setupResult = .cameraNotAuthorized
        }
        
        // Setup the capture session.
        // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
        // Why not do all of this on the main queue?
        // Because -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue
        // so that the main queue isn't blocked, which keeps the UI responsive.
        sessionQueue.async { () -> Void in
            self.setupCaptureSession()
        }
    }
    
    // Setup the capture session
    fileprivate func setupCaptureSession(){
        if setupResult != .success{
            return
        }
        
        do {
            let videoDevice = try type(of: self).deviceWithMediaType(AVMediaTypeVideo, preferringPosition: .back)
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            session.beginConfiguration()
            if session.canAddInput(videoDeviceInput) {
                
                /*
                 NSNotificationCenter.defaultCenter().addObserver(self, selector: "subjectAreaDidChange:", name: AVCaptureDeviceSubjectAreaDidChangeNotification, object: videoDeviceInput.device)*/
                
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
                DispatchQueue.main.async {
                    // Why are we dispatching this to the main queue?
                    // Because AVCaptureVideoPreviewLayer is the backing layer for AAPLPreviewView and UIView
                    // can only be manipulated on the main thread.
                    // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes
                    // on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                    
                    // Use the status bar orientation as the initial video orientation. Subsequent orientation changes are handled by
                    // -[viewWillTransitionToSize:withTransitionCoordinator:].
                    
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    var initialVideoOrientation:AVCaptureVideoOrientation = .portrait
                    
                    if statusBarOrientation != .unknown {
                        initialVideoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue)!
                    }
                    self.previewLayer.connection.videoOrientation = initialVideoOrientation
                }
            } else {
                print("Could not add video device input to the session")
                self.setupResult = .sessionConfigurationFailed
            }
            
            session.commitConfiguration()
        }catch{
            print("Could not create video device input: \(error)")
        }
    }
}

// MARK: - Start & Stop Camera Session
extension VideoCaptureViewController{
    // Start Camera Session
    func startCameraSession(){
        if case .success = setupResult{
            addObservers()
            session.startRunning()
            sessionRunning = session.isRunning
        }
    }
    
    // Stop Camera Session
    func stopCameraSession(){
        if self.setupResult == .success {
            self.session.stopRunning()
            sessionRunning = session.isRunning
            removeObservers()
        }
    }
}

// MARK: - Observers Managing.
extension VideoCaptureViewController{
    func addObservers(){
        // Add session running observer
        session.addObserver(self, forKeyPath: "isRunning", options: [.new], context: &sessionRunningContext)
        NotificationCenter.default.then{
            if let videoDeviceInput = videoDeviceInput {
                $0.addObserver(self, selector: #selector(subjectAreaDidChange(_:)), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
            }
            $0.addObserver(self, selector: #selector(sessionRuntimeError(_:)), name: .AVCaptureSessionRuntimeError, object: session)
            
            // A session can only run when the app is full screen. It will be interrupted in a multi-app layout, introduced in iOS 9,
            // see also the documentation of AVCaptureSessionInterruptionReason. Add observers to handle these session interruptions
            // and show a preview is paused message. See the documentation of AVCaptureSessionWasInterruptedNotification for other
            // interruption reasons.
            
            $0.addObserver(self, selector: #selector(sessionWasInterrupted(_:)), name: .AVCaptureSessionWasInterrupted, object: session)
            $0.addObserver(self, selector: #selector(sessionInterruptionEnded(_:)), name: .AVCaptureSessionInterruptionEnded, object: session)
        }
    }
    
    func removeObservers(){
        
        // Remove all notification observers.
        NotificationCenter.default.removeObserver(self)
        
        // Also remove KVO observing
        session.removeObserver(self, forKeyPath: "isRunning", context: &sessionRunningContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &sessionRunningContext {
            if let boolValue = change?[.newKey] as? Bool {
                isCaptureSessionRunning = boolValue
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - NSNotification Handlers
    // When Subject Area Changed.
    func subjectAreaDidChange(_ notification:Notification){
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        focusWithMode(.continuousAutoFocus, exposeWithMode: .continuousAutoExposure, atDevicePoint: devicePoint, monitorSubjectAreaChange: false)
    }
    
    // When session runtime error occured.
    func sessionRuntimeError(_ notification:Notification){
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? NSError else {
            return
        }
        
        isTorchOn = false
        
        print("Capture session runtime error : \(error)")
        
        // Automatically try to restart the session running if media services were reset and the last start running succeeded.
        // Otherwise, enable the user to try to resume the session running.
        
        if error.code == AVError.mediaServicesWereReset.rawValue {
            sessionQueue.async{
                if self.sessionRunning {
                    self.session.startRunning()
                    self.sessionRunning = self.session.isRunning
                } else {
                    DispatchQueue.main.async{
                        self.isSessionResumable = true
                    }
                }
            }
        } else {
            isSessionResumable = true
        }
    }
    
    // When session is interrupted by some reason
    func sessionWasInterrupted(_ notification:Notification){
        // In some scenarios we want to enable the user to resume the session running.
        // For example, if music playback is initiated via control center while using AVCam,
        // then the user can let AVCam resume the session running, which will stop music playback.
        // Note that stopping music playback in control center will not automatically resume the session running.
        // Also note that it is not always possible to resume, see -[resumeInterruptedSession:].
        var showResumeButton = false
        
        isTorchOn = false
        
        // In iOS 9 and later, the userInfo dictionary contains information on why the session was interrupted.
        if #available(iOS 9.0, *){
            
            guard let reasonRaw = (notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as? NSNumber)?.intValue,
                let reason = AVCaptureSessionInterruptionReason(rawValue: reasonRaw) else { return } //This should not be happened.
            
            print("Capture session was interrupted with reason \(reason)")
            
            switch reason {
            case .audioDeviceInUseByAnotherClient, .videoDeviceInUseByAnotherClient:
                showResumeButton = true
            case .videoDeviceNotAvailableWithMultipleForegroundApps:
                isCameraUnavailable = true
            default:
                break
            }
        } else {
            print("Capture session was interrupted.")
            showResumeButton = UIApplication.shared.applicationState == .inactive
        }
        
        if showResumeButton {
            isSessionResumable = true
        }
    }
    
    // When session interruption ended.
    func sessionInterruptionEnded(_ notification:Notification){
        print("Capture session interruption ended.")
        isCameraUnavailable = false
        isSessionResumable = false
    }
}

// MARK: - Resume interrupted session
extension VideoCaptureViewController{
    func resumeInterruptedSession(completion:@escaping (Error?)->Void){
        // The session might fail to start running, e.g., if a phone or FaceTime call is still using audio or video.
        // A failure to start the session running will be communicated via a session runtime error notification.
        // To avoid repeatedly failing to start the session running, we only try to restart the session running in the
        // session runtime error handler if we aren't trying to resume the session running.
        self.sessionQueue.async{
            self.session.startRunning()
            self.sessionRunning = self.session.isRunning
            guard self.session.isRunning else {
                DispatchQueue.main.async{
                    self.isSessionResumable = false
                    completion(CameraError.unableToResume)
                }
                return
            }
            
            self.isSessionResumable = false     // As this is running.
            DispatchQueue.main.async {
                completion(nil)
            }
        }
    }
}

// MARK: - Focus Utility
extension VideoCaptureViewController{
    /**
     This function should be connected to the real view controller (Sub View Controller)
     */
    @IBAction func focusAndExposeTap(_ gestureRecognizer:UIGestureRecognizer) {
        let devicePt = previewLayer.captureDevicePointOfInterest(for: gestureRecognizer.location(in: gestureRecognizer.view))
        focusWithMode(.autoFocus, exposeWithMode: .autoExpose, atDevicePoint: devicePt, monitorSubjectAreaChange: true)
    }
    
    func focusCenterPoint(){
        let point = CGPoint(x: 0.5, y: 0.5)
        focusWithMode(.continuousAutoFocus, exposeWithMode: .continuousAutoExposure, atDevicePoint: point, monitorSubjectAreaChange: false)
    }
    
    func focusWithMode(_ mode:AVCaptureFocusMode, exposeWithMode expMode:AVCaptureExposureMode, atDevicePoint point:CGPoint, monitorSubjectAreaChange change:Bool){
        sessionQueue.async{
            guard let device = self.videoDeviceInput?.device else {
                return
            }
            do {
                try device.lockForConfiguration()
                if device.isFocusModeSupported(mode) && device.isFocusPointOfInterestSupported {
                    device.focusPointOfInterest = point
                    device.focusMode = mode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(expMode) {
                    device.exposurePointOfInterest = point
                    device.exposureMode = expMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = change
                device.unlockForConfiguration()
            }catch{
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    /// Toggle Torch
    func toggleTorch() {
        sessionQueue.async {
            func setTorchOn(_ on:Bool){
                DispatchQueue.main.async {[weak self] in
                    self?.isTorchOn = on
                }
            }
            
            guard let device = self.videoDeviceInput?.device else {
                setTorchOn(false)
                return
            }
            
            let oppositeMode = !device.torchMode.boolValue
            let newMode = AVCaptureTorchMode(boolValue: oppositeMode)
            let isTorchOn = type(of:self).setTorchMode(newMode, forDevice: device)
            
            setTorchOn(isTorchOn)
        }
    }
}

// MARK: - Change Camera
extension VideoCaptureViewController {
    // Toggle camera
    func changeCamera(beforeCommit:(() -> Void)? = nil, completion:(() -> Void)? = nil){
        func callCompletion(){
            if let completion = completion {
                DispatchQueue.main.async(execute: completion)
            }
        }
        sessionQueue.async {
            guard
                let oldVideoDeviceInput = self.videoDeviceInput,
                let currentVideoDevice = oldVideoDeviceInput.device else {
                    callCompletion()
                    return
            }
            
            var preferredPosition:AVCaptureDevicePosition = .unspecified
            let currentPosition = currentVideoDevice.position
            switch currentPosition {
            case .unspecified, .front:
                preferredPosition = .back
            case .back:
                preferredPosition = .front
            }
            
            guard let videoDevice = try? type(of: self).deviceWithMediaType(AVMediaTypeVideo, preferringPosition: preferredPosition),
                let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice) else {
                    callCompletion()
                    return
            }
            
            self.session.beginConfiguration()
            
            // Remove the existing device input first, since using the front and back camera simultaneously is not supported.
            self.session.removeInput(oldVideoDeviceInput)
            
            if self.session.canAddInput(videoDeviceInput) {
                NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                type(of:self).setFlashMode(.auto, forDevice: videoDevice)
                NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange(_:)), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDevice)
                
                self.session.addInput(videoDeviceInput)
                
                // Set self's videoDeviceInput to newly added video device input
                self.videoDeviceInput = videoDeviceInput
            } else {
                // Insert original videoDeviceInput
                self.session.addInput(self.videoDeviceInput)
            }
            
            beforeCommit?()
            self.session.commitConfiguration()
            
            // Completed completed
            callCompletion()
        }
    }
}

// MARK: - Class functions for Get Capture Device, Flash Mode
extension VideoCaptureViewController {
    /**
     Returns device with preferred position
     */
    class func deviceWithMediaType(_ type:String, preferringPosition position:AVCaptureDevicePosition) throws -> AVCaptureDevice{
        
        guard let devices = AVCaptureDevice.devices(withMediaType: type) as? [AVCaptureDevice] else{
            throw CameraError.noCaptureDevice
        }
        
        guard let captureDevice = devices.first else {
            throw CameraError.noCaptureDevice
        }
        
        for device in devices {
            if device.position == position{
                return device
            }
        }
        return captureDevice
    }
    
    /**
     Flash Mode when taking photograph
     */
    class func setFlashMode(_ mode:AVCaptureFlashMode, forDevice device:AVCaptureDevice){
        if device.hasFlash && device.isFlashModeSupported(mode) {
            do{
                try device.lockForConfiguration()
                device.flashMode = mode
                device.unlockForConfiguration()
            }catch{
                print("Could not lock device for configuration: \(error)")
            }
        }
    }
    
    /**
     Torch Mode
     Return true if torch became on, else return false.
     - Parameter mode : AVCaptureTorchMode
     - Parameter device : AVCaptureDevice
     - Returns: if torch became on, return true else return false
     */
    @discardableResult
    class func setTorchMode(_ mode:AVCaptureTorchMode, forDevice device:AVCaptureDevice) -> Bool{
        if device.hasTorch && device.isTorchModeSupported(mode) {
            do{
                try device.lockForConfiguration()
                device.torchMode = mode
                device.unlockForConfiguration()
            }catch{
                print("Could not lock device for configuration: \(error)")
            }
            return device.torchMode.boolValue
        }
        return false
    }
}

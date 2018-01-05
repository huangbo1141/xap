//
//  AppDelegate.swift
//  HitchJob
//
//  Created by Alex on 10/1/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import SwiftLocation
import CoreData
import FBSDKCoreKit
import Bolts
import UserNotifications
import RxSwift
import Reachability

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate, UNUserNotificationCenterDelegate,CLLocationManagerDelegate {

    var window: UIWindow?

    var signInWithGoogleHandler: ((String, String, String, String) -> ())? = nil
    var locationManager = CLLocationManager.init()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
        checkReachability()
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().clientID = "770895927534-le82t6q09qn8cfahmcbg5b2e3e22p91q.apps.googleusercontent.com"
        
        registerForPushNotifications()
        startLocationService()
        
        // SignIn silently if userCredential is exist
        if AppContext.shared.userCredentials.userId > 0 {
            APIManager.default.userInfo(id: AppContext.shared.userCredentials.userId)
                .flatMap { json -> Observable<()> in
                    guard let user = try? User.createUser(in: AppContext.shared.mainContext, json: json) else { return Observable.just() }
                    AppContext.shared.currentUser = user
                    AppContext.shared.startUpdatingMessages()
                    return APIManager.default.setDeviceToken(userId: user.id, token: AppContext.shared.userCredentials.deviceToken)
                }.subscribe().addDisposableTo(rx_disposeBag)
        }
        
        return true
    }

    func startLocationService() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        locationManager.startUpdatingLocation()
        
        if CLLocationManager.locationServicesEnabled() {
            switch(CLLocationManager.authorizationStatus()){
            case .notDetermined:
                locationManager.requestWhenInUseAuthorization()
                print("no access")
            case .restricted,.denied:
                print("no access")
                let av = UIAlertView.init(title: "Location Service", message: "Location services were previously denied by the you. Please enable location services for this app in settings.", delegate: nil, cancelButtonTitle: "OK")
                av.show();
                return;
                
            case .authorizedAlways,.authorizedWhenInUse:
                print("access")
            }
            
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }else{
            let av = UIAlertView.init(title: "Location Service", message: "Location services were previously denied by the you. Please enable location services for this app in settings.", delegate: nil, cancelButtonTitle: "OK")
            av.show();
            
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        let googleHandled = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        
        let parsedURL = BFURL(inboundURL: url, sourceApplication: sourceApplication)
        if let appLinkData = parsedURL?.appLinkData {
            let targetUrl = parsedURL!.targetURL
            print(targetUrl)
        }
        
        return fbHandled || googleHandled || (parsedURL != nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        
        let email = user.profile.email ?? ""
        let userName = user.profile.name ?? ""
        let firstName = user.profile.givenName ?? ""
        let lastName = user.profile.familyName ?? ""
        
        signInWithGoogleHandler?(email, userName, firstName, lastName)
    }
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        
    }
    
    // Push notification
    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            guard granted else { return }
            self.getNotificationSettings()
        }
    }
    
    func unregisterForPushNotifications() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }
    
    func getNotificationSettings() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            print("Notification settings: \(settings)")
            guard settings.authorizationStatus == .authorized else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        
        let token = tokenParts.joined()
        
        AppContext.shared.userCredentials.deviceToken = token
        AppContext.shared.userCredentials.save()
        
        print("Device Token: \(token)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        print(userInfo)
        
        if application.applicationState == UIApplicationState.inactive ||
            application.applicationState == UIApplicationState.background {
            
            let data = userInfo["data"] as! [String: Any]
            
            AppContext.shared.notifData = data
            NotificationCenter.default.post(name: Notification.Name("PushNotification") , object: nil)
            
        }
        
    }
    
    func checkReachability() {
        let reachability = Reachability(hostname: "xap.com.es")
        
        reachability?.whenReachable = { _ in
            AppContext.shared.isReachable = true
        }
        
        reachability?.whenUnreachable = { _ in
            AppContext.shared.isReachable = false
        }
        
        try? reachability?.startNotifier()
    }
    var location:CLLocation?
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count>0{
            let lc = locations[0];
            
            print("app_lat",lc.coordinate.latitude)
            print("app_lng",lc.coordinate.longitude)
            self.location = lc
        }
    }
}


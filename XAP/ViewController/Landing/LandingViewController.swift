//
//  LandingViewController.swift
//  XAP
//
//  Created by Alex on 18/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class LandingViewController: UIViewController {

    var viewModel = LandingViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.signInWithGoogleHandler = signInWithGoogle
        
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func signinButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.landingScene.signInVC()
        vc.selectedSignIn = true
        vc.viewModel = viewModel
        vc.dismissCallback = { [weak self] in
            self?.dismiss(animated: false)
        }
        present(vc, animated: true)
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.landingScene.signInVC()
        vc.selectedSignIn = false
        vc.viewModel = viewModel
        vc.dismissCallback = { [weak self] in
            self?.dismiss(animated: false)
        }
        present(vc, animated: true)
    }
    
    @IBAction func faceBookLoginButtonTapped(_ sender: Any) {
        
        guard AppContext.shared.isReachable else {
            rx.alert(title: "Network Error".localized, message: "App couldn't connect to our server, because of your network condition.\nPlease check your network and refresh.", cancelTitle: "OK").subscribe().addDisposableTo(rx_disposeBag)
            
            return
        }
        
        let loginManager = FBSDKLoginManager()
        loginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { [weak self] loginResult, error in
            guard let _self = self else { return }
            guard error == nil else {
                print(error!.localizedDescription)
                return
            }
            guard let _loginResult = loginResult, !_loginResult.isCancelled else { return }
            guard _loginResult.grantedPermissions.contains("public_profile") else { return }
            
            let hud = _self.showActivityHUDTopMost()
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id,email,name,first_name,last_name"]).start(completionHandler: { connection, graphResult, error in
                guard let _graph = graphResult as? [String: Any], error == nil else {
                    hud.hide(animated: true)
                    return
                }
                
                let email = _graph["email"] as? String ?? ""
                let name = _graph["name"] as? String ?? ""
                let firstName = _graph["first_name"] as? String ?? ""
                let lastName = _graph["last_name"] as? String ?? ""
                
                _self.viewModel.signinFacebook(email: email, name: name, firstName: firstName, lastName: lastName)
                    .subscribe { evt in
                        hud.hide(animated: true)
                        switch evt {
                        case .next:
                            _self.presentingViewController?.dismiss(animated: true)
                        case .error(let error):
                            print(error.localizedDescription)
                            _self.ext_messages.show(type: .error, body: "Failed to Login using your Facebook account".localized, vc: _self)
                        default:
                            break
                        }
                    }.addDisposableTo(_self.rx_disposeBag)
            })
        }
    }
    
    @IBAction func googleLoginButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func signInWithGoogle(_ email: String, _ userName: String, _ firstName: String, _ lastName: String) {
        
        guard AppContext.shared.isReachable else {
            rx.alert(title: "Network Error".localized, message: "App couldn't connect to our server, because of your network condition.\nPlease check your network and refresh.", cancelTitle: "OK").subscribe().addDisposableTo(rx_disposeBag)
            
            return
        }
        
        let hud = showActivityHUDTopMost()
        viewModel.signinGoogle(email: email, name: userName, firstName: firstName, lastName: lastName)
            .subscribe { [weak self] evt in
                hud.hide(animated: true)
                guard let _self = self else { return }
                switch evt {
                case .next:
                    _self.presentingViewController?.dismiss(animated: true)
                case .error(let error):
                    print(error.localizedDescription)
                    _self.ext_messages.show(type: .error, body: "Failed to Login using your Google account".localized, vc: _self)
                default:
                    break
                }
        }.addDisposableTo(rx_disposeBag)
    }
}

extension LandingViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
}

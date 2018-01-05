//
//  GooglePlusVerifyViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class GooglePlusVerifyViewController: UIViewController {

    var viewModel: ProfileViewModel!
    
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
    
    @IBAction func googleVerifyButtonTapped(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    func signInWithGoogle(_ email: String, _ userName: String, _ firstName: String, _ lastName: String) {
        let hud = showActivityHUDTopMost()
        viewModel.verifyGoogle(google: email)
            .subscribe { [weak self] evt in
                hud.hide(animated: true)
                guard let _self = self else { return }
                switch evt {
                case .next:
                    _self.ext_messages.show(type: .success, body: "Google account is successfully verified.".localized, vc: nil)
                    _ = _self.popViewController()
                case .error(let error):
                    print(error.localizedDescription)
                    _self.ext_messages.show(type: .error, body: "Failed to verify your Google account".localized, vc: nil)
                default:
                    break
                }
        }.addDisposableTo(rx_disposeBag)
    }
}

extension GooglePlusVerifyViewController: GIDSignInUIDelegate {
    func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
        
    }
    
    func sign(_ signIn: GIDSignIn!, dismiss viewController: UIViewController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, present viewController: UIViewController!) {
        self.present(viewController, animated: true, completion: nil)
    }
}

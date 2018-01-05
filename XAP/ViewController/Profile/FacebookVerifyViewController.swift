//
//  FacebookVerifyViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FacebookVerifyViewController: UIViewController {

    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }

    @IBAction func verifyFacebookButtonTapped(_ sender: Any) {
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
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, email"]).start { [weak self] connection, graphResult, error in
                guard let _graph = graphResult as? [String: Any], error == nil else {
                    hud.hide(animated: true)
                    return
                }
                guard let email = _graph["email"] as? String, email != "" else {
                    hud.hide(animated: true)
                    return
                }
                
                _self.viewModel.verifyFacebook(facebook: email)
                    .subscribe { evt in
                        hud.hide(animated: true)
                        switch evt {
                        case .next:
                            _self.ext_messages.show(type: .success, body: "Facebook account is successfully verified".localized, vc: nil)
                            _ = _self.popViewController()
                        case .error(let e):
                            print(e.localizedDescription)
                            _self.ext_messages.show(type: .error, body: "Failed to verify your Facebook account".localized, vc: nil)
                        default:
                            break
                        }
                }.addDisposableTo(_self.rx_disposeBag)
            }
        }
    }
}

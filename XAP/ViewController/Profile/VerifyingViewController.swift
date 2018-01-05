//
//  VerifyingViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class VerifyingViewController: UIViewController {

    @IBOutlet weak var emailVerificationMark: UIImageView!
    @IBOutlet weak var phoneVerificationMark: UIImageView!
    @IBOutlet weak var facebookVerificationMark: UIImageView!
    @IBOutlet weak var googleVerificationMark: UIImageView!
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initUI()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initUI() {
        guard let _currentUser = AppContext.shared.currentUser else { return }
        
        facebookVerificationMark.isHidden = _currentUser.facebook != "" ? false : true
        googleVerificationMark.isHidden = _currentUser.google != "" ? false : true
        emailVerificationMark.isHidden = _currentUser.verifyEmail == "verified" ? false : true
        phoneVerificationMark.isHidden = _currentUser.verifyPhone == "verified" ? false : true
    }
    
    @IBAction func backBarButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch identifier {
        case "segue_to_facebook_verification":
            if !facebookVerificationMark.isHidden {
                return false
            }
        case "segue_to_google_verification":
            if !googleVerificationMark.isHidden {
                return false
            }
        default:
            break
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }
        switch identifier {
        case "segue_to_facebook_verification":
            (segue.destination as! FacebookVerifyViewController).viewModel = viewModel
        case "segue_to_google_verification":
            (segue.destination as! GooglePlusVerifyViewController).viewModel = viewModel
        default:
            break
        }
    }
    
    @IBAction func verifyEmailButtonTapped(_ sender: Any) {
        guard let email = AppContext.shared.currentUser?.email, email != "" else {
            ext_messages.show(type: .warning, body: "Email address is not exist.\nPlease try again after input Email address on profile setting.".localized, vc: nil)
            return
        }
        let hud = showActivityHUDTopMost()
        viewModel.verifyEmail().subscribe { [weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            
            switch evt {
            case .next:
                _self.ext_messages.show(type: .success, body: "Verification email sent.".localized, vc: nil)
            case .error(let error):
                print(error.localizedDescription)
                _self.ext_messages.show(type: .error, body: "Failed to send verification email".localized, vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
}

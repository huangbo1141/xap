//
//  ForgotPasswordViewController.swift
//  XAP
//
//  Created by Alex on 15/10/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import RxSwift

class ForgotPasswordViewController: UIViewController {

    @IBOutlet weak var inputFormView: UIView!
    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.indicatorImageView.alpha = 0
        self.inputFormView.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.5, animations: {
            self.indicatorImageView.alpha = 1.0
            self.inputFormView.alpha = 1.0
        })
    }
    

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func forgotPasswordButtonTapped(_ sender: Any) {
        let rules: [ValidationRuleProtocol] = [
            ExistenceValidationRule(emailTextField, "Please input Email address.".localized),
            EmailValidationRule(emailTextField, "Please input correct Email address.".localized),
            ]
        
        guard ext_validator.validate(rules: rules, vc: self) else { return }
        
        let hud = showActivityHUDTopMost()
        APIManager.default.forgetPassword(email: emailTextField.text!)
            .subscribe { [weak self] evt in
                hud.hide(animated: true)
                switch evt {
                case .next:
                    self?.ext_messages.show(type: .success, body: "Please check email on your Email address's inbox.".localized, vc: self)
                case .error(let error):
                    print(error.localizedDescription)
                    self?.ext_messages.show(type: .error, body: "Failed to find forgotten password.".localized, vc: self)
                default:
                    break
                }
            }.addDisposableTo(rx_disposeBag)
    }
    
}

//
//  SignInViewController.swift
//  XAP
//
//  Created by Alex on 18/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import RxSwift

class SignInViewController: UIViewController {
    
    var dismissCallback: ((Void) -> ())?

    @IBOutlet weak var indicatorImageView: UIImageView!
    @IBOutlet weak var indicatorImageViewCenterConstraint: NSLayoutConstraint!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var signinView: UIView!
    @IBOutlet weak var registerFirstNameTextField: UITextField!
    
    @IBOutlet weak var signinButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var signinTabButton: UIButton!
    @IBOutlet weak var signinEmailTextField: UITextField!
    @IBOutlet weak var signInPasswordTextField: UITextField!
    @IBOutlet weak var registerTabButton: UIButton!
    @IBOutlet weak var registerEmailTextField: UITextField!
    @IBOutlet weak var registerPasswordTextField: UITextField!
    
    @IBOutlet weak var passwordShowButton: UIButton!
    
    var viewModel: LandingViewModel!
    
    var isPasswordShow = false {
        didSet {
            registerPasswordTextField.isSecureTextEntry = !isPasswordShow
            if isPasswordShow {
                passwordShowButton.setImage(#imageLiteral(resourceName: "ic_visibility"), for: .normal)
            } else {
                passwordShowButton.setImage(#imageLiteral(resourceName: "ic_visibility_off_gray"), for: .normal)
            }
        }
    }
    
    var selectedSignIn = true {
        didSet {
            guard isViewLoaded else { return }
            if selectedSignIn {
                UIView.animate(withDuration: 1, animations: {
                    self.indicatorImageView.frame = CGRect(center: CGPoint(x: self.signinTabButton.center.x, y: self.signinTabButton.frame.maxY + self.indicatorImageView.frame.height / 2), size: self.indicatorImageView.frame.size)
                    self.indicatorImageViewCenterConstraint.constant = self.signinTabButton.center.x
                    self.signinView.alpha = 1.0
                    self.registerView.alpha = 0.0
                })
            } else {
                UIView.animate(withDuration: 1, animations: {
//                    self.indicatorImageViewCenterConstraint.constant = self.registerTabButton.center.x
                    self.indicatorImageView.frame = CGRect(center: CGPoint(x: self.registerTabButton.center.x, y: self.registerTabButton.frame.maxY + self.indicatorImageView.frame.height / 2), size: self.indicatorImageView.frame.size)
                    self.signinView.alpha = 0.0
                    self.registerView.alpha = 1.0
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        indicatorImageView.alpha = 0.0
        signinView.alpha = 0.0
        registerView.alpha = 0.0
        
        initUI()
    }
    
    func initUI() {
//        initValidation()
    }
    
    func initValidation() {
        let signinValidEmail = signinEmailTextField.rx.text.orEmpty.map{ $0.isValidEmail }.shareReplay(1)
        let signinValidPassword = signInPasswordTextField.rx.text.orEmpty.map { _ in return true }.shareReplay(1)
        
        let signinValid = Observable.combineLatest(signinValidEmail, signinValidPassword) { email, password -> Bool in
            return email && password
        }
        
        signinValid.bind(to: signinButton.rx.isEnabled).addDisposableTo(rx_disposeBag)
        
        let registerValidName = registerFirstNameTextField.rx.text.orEmpty.map { _ in return true }.shareReplay(1)
        let registerValidEmail = registerEmailTextField.rx.text.orEmpty.map{ $0.isValidEmail }.shareReplay(1)
        let registerValidPassword = registerPasswordTextField.rx.text.orEmpty.map { $0.characters.count > 8 }.shareReplay(1)
        
        let registerValid = Observable.combineLatest(registerValidName, registerValidEmail, registerValidPassword) { name, email, password -> Bool in
            return name && email && password
        }
        
        registerValid.bind(to: registerButton.rx.isEnabled).addDisposableTo(rx_disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if selectedSignIn {
            indicatorImageView.frame = CGRect(center: CGPoint(x: signinTabButton.center.x, y: signinTabButton.frame.maxY + indicatorImageView.frame.height / 2), size: indicatorImageView.frame.size)
            UIView.animate(withDuration: 0.5, animations: { 
                self.signinView.alpha = 1.0
                self.indicatorImageView.alpha = 1.0
            })
        } else {
//            indicatorImageViewCenterConstraint.constant = registerTabButton.center.x
            indicatorImageView.frame = CGRect(center: CGPoint(x: registerTabButton.center.x, y: registerTabButton.frame.maxY + indicatorImageView.frame.height / 2), size: indicatorImageView.frame.size)
            UIView.animate(withDuration: 0.5, animations: {
                self.registerView.alpha = 1.0
                self.indicatorImageView.alpha = 1.0
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func backButtonTapped(_ sender: Any) {
        dismiss(animated: true)
    }
    
    @IBAction func signInTabButtonTapped(_ sender: Any) {
        selectedSignIn = true
    }
    
    @IBAction func registerTabButtonTapped(_ sender: Any) {
        selectedSignIn = false
    }
    
    @IBAction func registerPasswordSeenButtonTapped(_ sender: Any) {
        isPasswordShow = !isPasswordShow
    }
    
    @IBAction func siginButtonTapped(_ sender: Any) {
        
        guard AppContext.shared.isReachable else {
            rx.alert(title: "Network Error".localized, message: "App couldn't connect to our server, because of your network condition.\nPlease check your network and refresh.", cancelTitle: "OK").subscribe().addDisposableTo(rx_disposeBag)
            
            return
        }
        
        let rules: [ValidationRuleProtocol] = [
                    ExistenceValidationRule(signinEmailTextField, "Please input Email address.".localized),
                    EmailValidationRule(signinEmailTextField, "Please input correct Email address.".localized),
                    ExistenceValidationRule(signInPasswordTextField, "Please input Password.".localized)
                ]
        
        guard ext_validator.validate(rules: rules, vc: self) else { return }
        
        let hud = showActivityHUDTopMost()
        viewModel.signIn(email: signinEmailTextField.text!, password: signInPasswordTextField.text!)
            .subscribe { [weak self] evt in
                hud.hide(animated: true)
                guard let _self = self else { return }
                
                switch evt {
                case .next:                    _self.presentingViewController?.presentingViewController?.dismiss(animated: true)
                case .error(let error):
                    print(error.errorMessage(message: "Failed to Signin".localized))
                    _self.ext_messages.show(type: .error, body: "Invalid Email/Password. Please input valid informations.".localized, vc: _self)
                default:
                    break
                }
        }.addDisposableTo(rx_disposeBag)
    }
    func callFunc(){
        let hud = showActivityHUDTopMost()
        let to:String = registerEmailTextField.text!
        let body:String = "<a href='http://82.223.19.247/xap/api/signup_confirm.php?token=" + String(AppContext.shared.currentUserID) + "'>Please click this link for confirm</a>"
        //        APIManager.default.callFunc1(to:to,body:"",subject:"Welcome to sign up")
        //            .subscribe { [weak self] evt in
        //                hud.hide(animated: true)
        //                switch evt {
        //                case .next:
        //                    self?.presentingViewController?.presentingViewController?.dismiss(animated: true)
        //                case .error(let error):
        //                    print(error.localizedDescription)
        //                    self?.ext_messages.show(type: .error, body: "Failed to find forgotten password.".localized, vc: self)
        //                default:
        //                    break
        //                }
        //            }.addDisposableTo(rx_disposeBag)
        //
        //        let serverurl = Constants.kGoogleAutoCompleteAPI + CGlobal.urlencode(searchKey)
        
        let data:NSMutableDictionary = NSMutableDictionary()
        data["to"] = to
        data["body"] = body
        data["subject"] = "Welcome Sign up"
        let serverurl = "http://82.223.19.247/webservice/include/test.php";
        let manager = NetworkParser.sharedManager()
        
        manager?.callNetwork(serverurl, data: data, withCompletionBlock: { (dict, error) in
            if let places = ApnModel.init(dictionary: dict) {
                debugPrint(places)
                if let x = Int(places.result){
                    if x == 1 {
                        hud.hide(animated: true)
                        self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: {
                            let alert = UIAlertView.init(title: nil, message: places.detail, delegate: nil, cancelButtonTitle: "OK")
                            alert.show()
                        })
                        
                    }
                }
            }
        }, method: "post");
    }
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        guard AppContext.shared.isReachable else {
            rx.alert(title: "Network Error".localized, message: "App couldn't connect to our server, because of your network condition.\nPlease check your network and refresh.", cancelTitle: "OK").subscribe().addDisposableTo(rx_disposeBag)
            
            return
        }
        var lat = ""
        var lng = ""
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        
        if let lc = appDelegate.location {
            lat = String.init(format: "%f", lc.coordinate.latitude);
            lng = String.init(format: "%f", lc.coordinate.longitude);
        }else{
            ext_validator.base.show(type: .warning, title: nil, body: "Location Not Detected", vc: self)
            return;
//            self.base.show(type: .warning, title: nil, body: rule.message, vc: vc)
        }
        
        let rules: [ValidationRuleProtocol] = [
                    ExistenceValidationRule(registerFirstNameTextField, "Please input UserName.".localized),
                    ExistenceValidationRule(registerEmailTextField, "Please input Email address.".localized),
                    EmailValidationRule(registerEmailTextField, "Please input correct Email address.".localized),
                    ExistenceValidationRule(registerPasswordTextField, "Please input Password.".localized),
                    LengthValidationRule(registerPasswordTextField, 8, "Password should be at least 8 characters.".localized),
                    
            
                ]
        
        guard ext_validator.validate(rules: rules, vc: self) else { return }
        
        let hud = showActivityHUDTopMost()
        viewModel.signUp(username: registerFirstNameTextField.text!, email: registerEmailTextField.text!, password: registerPasswordTextField.text!,lat:lat,lng:lng)
            .subscribe { [weak self] evt in
                hud.hide(animated: true)
                guard let _self = self else { return }
                
                switch evt {
                case .next:
                    self?.callFunc()
                case .error(let error):
                    print(error.errorMessage(message: "Failed to register user".localized))
                    _self.ext_messages.show(type: .error, body: error.errorMessage(message: "Failed to register user".localized), vc: _self)
                default:
                    break
                }
        }.addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func forgetPasswordButtonTapped(_ sender: Any) {
        let vc = XAPStoryboard.landingScene.forgotPasswordVC()
        present(vc, animated: true)
    }
}

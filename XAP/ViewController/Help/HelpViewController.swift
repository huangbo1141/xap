//
//  HelpViewController.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

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
    
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }
    
    @IBAction func termsAndConditionsTapped(_ sender: Any) {
    }
    @IBAction func privacyPolicyTapped(_ sender: Any) {
    }
    @IBAction func safetyGuidelinesTapped(_ sender: Any) {
    }
    @IBAction func xapRulesTapped(_ sender: Any) {
    }
    @IBAction func likeUsFacebookTapped(_ sender: Any) {
    }
    @IBAction func xapTwitterTapped(_ sender: Any) {
    }
    @IBAction func faqTapped(_ sender: Any) {
    }
    
    @IBAction func contactUsTapped(_ sender: Any) {
        
        let langId = Locale.current.languageCode
        let countryId = Locale.current.regionCode
        
        let vc: UIViewController
        if langId == "es" {
            vc = XAPStoryboard.helpScene.helpContactSpanishVC()
        } else {
            vc = XAPStoryboard.helpScene.helpContactEnglishVC()
        }
        
        show(vc, sender: nil)
    }
}

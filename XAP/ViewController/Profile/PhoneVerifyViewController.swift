//
//  PhoneVerifyViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class PhoneVerifyViewController: UIViewController {

    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var countryPhonePrefixTextField: CountryPickerField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        countryPhonePrefixTextField.countryPickerFieldDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let signaporeCountry = Country.from(countryCode: "SG")
        if signaporeCountry != nil {
            flagImageView.image = UIImage(named: signaporeCountry!.code!.lowercased())
            countryPhonePrefixTextField.text = signaporeCountry!.phoneCode!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func countryPickerFieldTapped(_ sender: Any) {
        countryPhonePrefixTextField.becomeFirstResponder()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
}

extension PhoneVerifyViewController : CountryPickerFieldDelegate {
    func countryPickerField(_ pickerField: CountryPickerField, didValueChangedWithCountryName countryName: String, countryCode: String, phoneCode: String) {
        let flagImage = UIImage(named: countryCode.lowercased())
        flagImageView.image = flagImage
    }
}

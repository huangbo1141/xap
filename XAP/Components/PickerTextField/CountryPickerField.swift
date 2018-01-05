//
//  CountryPickerField.swift
//  Shater
//
//  Created by Swift Coder on 10/23/16.
//  Copyright © 2016 swif coder. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

protocol CountryPickerFieldDelegate {
    func countryPickerField(_ pickerField: CountryPickerField, didValueChangedWithCountryName countryName: String, countryCode: String, phoneCode: String)
}

class CountryPickerField : NoCaretTextField {
    fileprivate let iav = ListPickerFieldAccessoryView.shared
    
    let disposeBag = DisposeBag()
    
    var countryPickerFieldDelegate : CountryPickerFieldDelegate?
    
    fileprivate lazy var countryPicker:CountryPicker = {
        return CountryPicker()
    }()
    
    var countryName: String = "" {
        didSet {

        }
    }
    
    var countryCode: String = ""
    
    var countryPhoneCode: String = "" {
        didSet {
            text = countryPhoneCode
            countryPickerFieldDelegate?.countryPickerField(self, didValueChangedWithCountryName: countryName, countryCode: countryCode, phoneCode: countryPhoneCode)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(textFieldDidBeginEditing(_:)),
            name: .UITextFieldTextDidBeginEditing,
            object: self)
        
        // Set input View
        inputView = countryPicker
        
        // Should skip first item
        countryPicker.rx.itemSelected.subscribe(onNext: {[weak self] _, _ in
            self?.countryName = self?.countryPicker.currentCountry?.name ?? ""
        }).addDisposableTo(disposeBag)
        countryPicker.countryPhoneCodeDelegate = self
    }
    
    func textFieldDidEndEditing(_ notification:Notification){
        guard let textField = notification.object as? CountryPickerField, self == textField else { return }
        iav.delegate = nil  //Clear Delegate
    }
    
    func textFieldDidBeginEditing(_ notification:Notification){
        guard let textField = notification.object as? CountryPickerField, self == textField else { return }
        
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension CountryPickerField:ListPickerFieldAccessoryViewDelegate {
    func didDoneButtonTapped(_ view: ListPickerFieldAccessoryView) {
        if let delegateFunc = delegate?.textFieldShouldReturn {
            // Call Should Return
            _ = delegateFunc(self)
        } else {
            // Resign First Responder.
            resignFirstResponder()
        }
    }
}

extension CountryPickerField: CountryPhoneCodePickerDelegate {
    func countryPhoneCodePicker(picker: CountryPicker, didSelectCountryCountryWithName name: String, countryCode: String, phoneCode: String) {
        self.countryName = name
        self.countryCode = countryCode
        self.countryPhoneCode = phoneCode
    }
}

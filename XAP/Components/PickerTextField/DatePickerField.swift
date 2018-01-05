//
//  DatePickerField.swift
//  XAP
//
//  Created by Alex on 25/3/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

class DatePickerField : NoCaretTextField {
    fileprivate let iav = ListPickerFieldAccessoryView.shared
    let disposeBag = DisposeBag()
    
    fileprivate lazy var datePicker:UIDatePicker = {
        return UIDatePicker().then{
            $0.datePickerMode = .date
        }
    }()
    
    fileprivate lazy var dateFormatter:DateFormatter = {
        return DateFormatter().then{
            $0.timeStyle = .none
            $0.dateStyle = .medium
        }
    }()
    
    var date:Date?{
        didSet {        
            guard let date = self.date else {
                text = ""
                return
            }
            text = dateFormatter.string(from: date)
            if datePicker.date != date {
                // reset date.
                datePicker.date = date
            }
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
        inputView = datePicker
        
        //Select Date if text field value is valid
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }

        // Should skip first item
        datePicker
            .rx.date
            .skip(1)
            .distinctUntilChanged()
            .subscribe(onNext:{[weak self] date in
                self?.date = date
        }).addDisposableTo(disposeBag)
    }
    
    func textFieldDidEndEditing(_ notification:Notification){
        guard let textField = notification.object as? DatePickerField, self == textField else { return }
        iav.delegate = nil  //Clear Delegate
    }
    
    func textFieldDidBeginEditing(_ notification:Notification){
        guard let textField = notification.object as? DatePickerField, self == textField else { return }
        
        iav.then{
            inputAccessoryView = $0
            $0.delegate = self
            $0.title = placeholder ?? ""
        }
        
        if let date = dateFormatter.date(from: text ?? "") {
            datePicker.date = date
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

extension DatePickerField:ListPickerFieldAccessoryViewDelegate {
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

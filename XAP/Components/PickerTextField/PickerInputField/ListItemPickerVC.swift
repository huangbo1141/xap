//
//  ListItemPickerVC.swift
//  AutoCorner
//
//  Created by Alex on 13/2/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

/**
    List Picker modal style view controller.
*/
import UIKit
import Cartography
import RxSwift
import RxCocoa

enum ListItemPickerResult<T:ListPickerItemType> {
    case picked(T)     // When picked an item
    case cancelled     // When cancelled.
}

class ListItemPickerVC<T:ListPickerItemType>: UIViewController {
    
    // ListPicker
    let picker = ListPicker<T>()
    
    // Picker Callback
    var action:((ListItemPickerResult<T>) -> ())?
    
    // When set data, also update picker view's data.
    var items:[T] {
        didSet {
            picker.items = items
        }
    }
    
    var pickerTitle:String
    
    init(items:[T], title:String = "Select", action:((ListItemPickerResult<T>) -> ())? = nil){
        self.items = items
        picker.items = items
        
        self.pickerTitle = title
        self.action = action
        
        super.init(nibName: nil, bundle: nil)
        // Setup Modal Transition Style & ...
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        picker.pickerView.then{
            $0.backgroundColor = .white
        }
        
        view = UIView().then{
            $0.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
            $0.addSubview(picker.pickerView)
        }
        
        // Setup Constraints.
        constrain(picker.pickerView){
            $0.center == $0.superview!.center
            $0.leading == $0.superview!.leading
            $0.trailing == $0.superview!.trailing
            $0.width == $0.superview!.width
        }
        
        // Add Ok, Cancel Button
        let okButton = createButton("OK", action: #selector(okButtonTapped(_:)))
        let cancelButton = createButton("CANCEL", action: #selector(cancelButtonTapped(_:)))
        
        let separator = UIView().then{
            $0.backgroundColor = .white
            view.addSubview($0)
        }
        
        let titleLabel = UILabel().then{
            $0.text = pickerTitle
            $0.backgroundColor = UIColor(hexString: "#F0F0F0")
            $0.textAlignment = .center
            $0.textColor = .lightGray
            view.addSubview($0)
        }
        
        constrain(okButton, cancelButton, separator, picker.pickerView){ok, cancel, separator, picker in
            ok.leading == picker.leading
            ok.trailing == picker.centerX
            cancel.leading == picker.centerX - 1
            cancel.trailing == picker.trailing
            ok.height == 44.0
            cancel.height == 44.0
            ok.top == picker.bottom
            cancel.top == picker.bottom
            separator.top == picker.bottom
            separator.width == 1.0
            separator.bottom == cancel.bottom
            separator.centerX == picker.centerX
        }
        
        constrain(titleLabel, picker.pickerView) { titleLabel, picker in
            titleLabel.leading == picker.leading
            titleLabel.trailing == picker.trailing
            titleLabel.height == 35
            titleLabel.bottom == picker.top
        }
        
        // Add Tap Gesture Recognizer to view.
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewTapped(_:))))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Create Default Button
    func createButton(_ title:String, action:Selector) -> UIButton{
        return UIButton().then{
            $0.setTitle(title, for: UIControlState())
            $0.isExclusiveTouch = true
            $0.addTarget(self, action: action, for: [.touchUpInside])
            $0.setBackgroundImage(UIImage.image(color: .red), for: .normal)
            view.addSubview($0)
        }
    }
    
    // MARK: - Action
    @IBAction func okButtonTapped(_ sender:AnyObject){
        // This should not normally happen
        guard let item = picker.selectedItem() else {
            return
        }
        let action = self.action
        dismiss(animated: true){
            action?(.picked(item))
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender:AnyObject){
        let action = self.action
        dismiss(animated: true){
            action?(.cancelled)
        }
    }
    
    // MARK: - View Tapped
    @IBAction func viewTapped(_ sender:AnyObject){
        // Simply call cancel button tapped.
        cancelButtonTapped(sender)
    }
}

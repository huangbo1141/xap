//
//  ListPickerView.swift
//  AutoCorner
//
//  Created by Alex on 6/2/2016.
//  Copyright © 2016 stockNumSystems. All rights reserved.
//

import UIKit

protocol ListPickerItemType : Equatable{
    var displayName:String { get }
}

extension String: ListPickerItemType{
    var displayName:String{
        return self
    }
}  // Make String Conform ListPickerItemType

protocol ListPickerDelegate: class {
    func listPicker<T:ListPickerItemType>(_ picker:ListPicker<T>, didSelectItem item:T)
}

/// Generic List Picker which interacts with UIPickerView & data.
class ListPicker<T:ListPickerItemType> : NSObject, UIPickerViewDataSource, UIPickerViewDelegate{
    let pickerView = UIPickerView()
    weak var delegate:ListPickerDelegate?
    
    var items:[T] = []{
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    override init(){
        super.init()
        pickerView.delegate = self
    }
    
    // DataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        guard component < items.count else {
            return 0
        }
        return items.count
    }
    
    // Delegate (Title for Row)
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return items[row].displayName
    }
    
    // Call delegate's did Select Item.
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.listPicker(self, didSelectItem: items[row])
    }
}

// MARK: - Returns currently selected items as array.
extension ListPicker{
    /// Returns first selected Item.
    func selectedItem() -> T? {
        let row = pickerView.selectedRow(inComponent: 0)
        guard row < items.count else {
            return nil
        }
        return items[row]
    }
    
    /// Select Item
    func selectItem(_ item:T){
        for (index, d) in items.enumerated() {
            if d == item{
                pickerView.selectRow(index, inComponent: 0, animated: true)
                return
            }
        }
    }
}

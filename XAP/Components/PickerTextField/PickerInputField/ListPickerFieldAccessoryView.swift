//
//  ListPickerFieldAccessoryView.swift
//  XAP
//
//  Created by Alex on 25/3/2016.
//  Copyright © 2016 JustTwoDudes. All rights reserved.
//

import UIKit

protocol ListPickerFieldAccessoryViewDelegate:class{
    func didDoneButtonTapped(_ view:ListPickerFieldAccessoryView)
}

fileprivate let kNibName = "ListPickerFieldAccessoryView"

class ListPickerFieldAccessoryView: UIView {
    fileprivate var view:UIView!
    
    static let shared:ListPickerFieldAccessoryView = {
        return ListPickerFieldAccessoryView()
    }()
    
    @IBOutlet weak var titleLabel: UILabel!
    weak var delegate:ListPickerFieldAccessoryViewDelegate?
    
    var title:String = ""{
        didSet {
            titleLabel.text = title
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        delegate?.didDoneButtonTapped(self)
    }
    
    
    convenience init(){
        self.init(frame: CGRect(x: 0, y: 0, width: 100, height: 44))
    }
    
    override init(frame: CGRect){
        // 1. setup any properties here
        
        // 2. call super.init(frame:)
        super.init(frame: frame)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    required init?(coder aDecoder: NSCoder){
        // 1. setup any properties here
        
        // 2. call super.init(coder:)
        super.init(coder: aDecoder)
        
        // 3. Setup view from .xib file
        xibSetup()
    }
    
    
    fileprivate func xibSetup(){
        let view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        
        // update frame
        frame = view.frame
    }
    
    fileprivate func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: kNibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
}

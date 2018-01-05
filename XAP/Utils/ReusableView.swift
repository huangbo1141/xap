//
//  ReusableView.swift
//  Cattivo VIA
//
//  Created by Alex on 13/9/2016.
//  Copyright © 2016 Cattivo Jewelery. All rights reserved.
//

import Foundation
import UIKit

// MARK: - ReusableView
protocol ReusableView : class { }

extension ReusableView where Self:UIView {
    static var reuseIdentifier: String {
        return String(describing:self)
    }
}

extension UITableViewCell: ReusableView { }
extension UICollectionViewCell: ReusableView { }

// MARK: - NibLoadableView
protocol NibLoadableView: class { }

extension NibLoadableView where Self: UIView {
    static var nibName:String {
        return String(describing:self)
    }
    
    static func nib() -> UINib{
        let bundle = Bundle(for: Self.self)
        return UINib(nibName: nibName, bundle: bundle)
    }
    
    static func loadView<T>(owner:AnyObject?, options:[String:AnyObject]? = nil) -> T where T:UIView{
        guard let instantiated = nib().instantiate(withOwner: owner, options:options)[0] as? T else {
            fatalError("Could not instantiate view with Type : \(T.self)")
        }
        return instantiated
    }
}

// MARK: - Self initializable nib view
/**
 NibInitializableView which can load view as its subview with flexible width and height.
 This type of view can be used in storyboard, and also can be instantiated with init(frame:)
 */
protocol NibInitializableView: NibLoadableView { }

extension NibInitializableView where Self: UIView {
    func loadView(options:[String:AnyObject]? = nil) -> UIView {
        let view:UIView = type(of: self).loadView(owner:self, options:options)
        view.frame = bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        return view
    }
}

// MARK: - UITableView
extension UITableView {
    func register<T:UITableViewCell>(_:T.Type) where T:ReusableView, T:NibLoadableView {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellReuseIdentifier: T.reuseIdentifier)
    }
    
    func dequeueReusableCell<T:UITableViewCell>(for ip:IndexPath) -> T where T:ReusableView{
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: ip) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
}

// MARK: - UICollectionView
extension UICollectionView{
    // Register part
    func register<T>(_:T.Type) where T:UICollectionViewCell, T:ReusableView, T:NibLoadableView {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
    }
    
    func register<T>(_:T.Type, forSupplementaryViewOfKind: String) where T:UICollectionReusableView, T:ReusableView, T:NibLoadableView {
        let nib = UINib(nibName: T.nibName, bundle: nil)
        register(nib, forSupplementaryViewOfKind: forSupplementaryViewOfKind, withReuseIdentifier: T.reuseIdentifier)
    }
    
    // Dequeue part
    func dequeueReusableCell<T>(for ip:IndexPath) -> T where T:UICollectionViewCell, T:ReusableView{
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: ip) as? T else {
            fatalError("Could not dequeue cell with identifier: \(T.reuseIdentifier)")
        }
        return cell
    }
    
    func dequeueReusableSupplementaryView<T>(ofKind: String, for ip:IndexPath) -> T where T:UICollectionReusableView, T:ReusableView{
        guard let view = dequeueReusableSupplementaryView(ofKind: ofKind, withReuseIdentifier: T.reuseIdentifier, for: ip) as? T else {
            fatalError("Could not dequeue reusable supplmentary view with identifier: \(T.reuseIdentifier)")
        }
        return view
    }
}

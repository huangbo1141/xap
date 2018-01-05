//
//  UIViewController+EasySlide.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation

extension UIViewController {
    func getEasySlide() -> ESNavigationController? {
        return self.navigationController as? ESNavigationController
    }
    
    func openLeftView(){
        self.getEasySlide()?.openMenu(.leftMenu, animated: true, completion: {})
    }
    
    func openRightView(){
        self.getEasySlide()?.openMenu(.rightMenu, animated: true, completion: {})
    }
}

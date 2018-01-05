//
//  AppDelegate+Theme.swift
//  JobinRecruiter
//
//  Created by Alex on 22/12/2016.
//  Copyright © 2016 Ali. All rights reserved.
//

import UIKit

extension AppDelegate {
    func setupTheme(){
        CustomFloatingTextField.appearance().borderActiveColor = .white
        CustomFloatingTextField.appearance().placeholderColor = .lightGray
        CustomFloatingTextField.appearance().borderInactiveColor = .lightGray
        CustomFloatingTextField.appearance().placeholderFontScale = 0.8
        UINavigationBar.appearance().tintColor = .black
    }
}

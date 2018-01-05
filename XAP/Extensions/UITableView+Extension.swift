//
//  UITableView+Extension.swift
//  JobinRecruiter
//
//  Created by Alex on 6/1/2017.
//  Copyright © 2017 Ali. All rights reserved.
//

import Foundation

extension UITableView {
    func removeLeftSeperatorMargin() {
        cellLayoutMarginsFollowReadableWidth = false
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
}

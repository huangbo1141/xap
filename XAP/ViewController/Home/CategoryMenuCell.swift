//
//  CategoryMenuCell.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class CategoryMenuCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    
    var category: Category! {
        didSet {
            titleLabel.text = category.rawValue.localized
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

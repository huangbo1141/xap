//
//  ChoosingReasonTableViewCell.swift
//  XAP
//
//  Created by Alex on 17/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class ChoosingReasonTableViewCell: UITableViewCell {

    @IBOutlet weak var reasonIcon: UIImageView!
    @IBOutlet weak var reasonLabel: UILabel!
    
    var reason: ReportReason! {
        didSet {
            reasonLabel.text = reason.string
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

//
//  BulletinTableViewCell.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import Kingfisher

class BulletinTableViewCell: UITableViewCell {

    @IBOutlet weak var bulletinImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    
    var bulletin: Bulletin! {
        didSet {
            bulletinImageView.kf.setImage(with: bulletin.imagePath, placeholder: #imageLiteral(resourceName: "item_placeholder"))
            titleLabel.text = bulletin.title
            contentLabel.text = bulletin.content
            timestampLabel.text = bulletin.timestamp.toDateString(format: "MM/dd/yyyy HH:mm")
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

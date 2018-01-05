//
//  ItemCollectionViewCell.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var markImageView: UIImageView!
    
    var contentImage: UIImage! {
        didSet {
            imageView.image = contentImage
//            imageViewHeightConstraint.constant = contentImage.height(forWidth: 100)
        }
    }
    
    var item: Item! {
        didSet {
            budgetLabel.text = "\(item.currency.rawValue) \(item.price)"
            
            nameLabel.text = item.title
            nameLabel.sizeToFit()
            
            if item.sold == true {
                markImageView.isHidden = false
                markImageView.image = #imageLiteral(resourceName: "ic_sold_mark")
            } else if item.reserved == true {
                markImageView.isHidden = false
                markImageView.image = #imageLiteral(resourceName: "ic_reserve_mark")
            } else {
                markImageView.isHidden = true
            }
        }
    }
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)

        if let attributes = layoutAttributes as? PinterestLayoutAttributes {
            imageViewHeightConstraint.constant = attributes.imageHeight
        }
    }
}

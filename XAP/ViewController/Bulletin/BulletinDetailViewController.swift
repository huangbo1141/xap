//
//  BulletinDetailViewController.swift
//  XAP
//
//  Created by Alex on 27/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import Kingfisher

class BulletinDetailViewController: UIViewController {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var bulletin: Bulletin!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back_arrow_white"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView.kf.setImage(with: bulletin.imagePath, placeholder: #imageLiteral(resourceName: "item_placeholder"))
        titleLabel.text = bulletin.title
        contentLabel.text = bulletin.content
        contentLabel.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.

    }
    
    func backButtonTapped() {
        _ = popViewController()
    }
}

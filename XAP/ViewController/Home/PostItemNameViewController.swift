//
//  PostItemNameViewController.swift
//  XAP
//
//  Created by Alex on 15/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import TagListView

class PostItemNameViewController: UIViewController {
    
    @IBOutlet weak var tagListView: TagListView!
    @IBOutlet weak var titleTextField: UITextField!
    
    let tags = ["iPhone5", "Meta", "Seat Ibiza", "Nevera", "Ps3", "Samsung galaxy", "sofa", "Bicicleta", "Casco Moto", "Vestido fiesta", "Coche"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

        initTagListView()
    }
    
    func initTagListView() {
        tagListView.alignment = .center
        tagListView.cornerRadius = 16
        tagListView.tagBackgroundColor = .lightGray
        tagListView.textColor = .darkGray
        tagListView.textFont = UIFont.systemFont(ofSize: 20)
        tagListView.paddingX = 16
        tagListView.paddingY = 12
        tagListView.marginX = 8
        tagListView.marginY = 8
        tagListView.addTags(tags)
        
        tagListView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        navigationController?.dismiss(animated: true)
    }
    
    @IBAction func confirmButtonTapped(_ sender: Any) {
        let title = titleTextField.text ?? ""
        guard title != "" else { return }
        
        confirm(title: title)
    }
    
    func confirm(title: String) {
        let vc = XAPStoryboard.postScene.postItemVC()
        vc.itemTitle = title
        show(vc, sender: nil)
    }
}

extension PostItemNameViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        confirm(title: title)
    }
}

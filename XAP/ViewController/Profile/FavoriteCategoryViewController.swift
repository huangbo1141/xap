//
//  FavoriteCategoryViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import TagListView

class FavoriteCategoryViewController: UIViewController {

    @IBOutlet weak var favoriteTagListView: TagListView!
    
    var selectedCategories: [Category] = []
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        initTagListView()
        
        selectedCategories = viewModel.userSetting.favCategories
        selectedCategories.forEach { category in
            let tagView = favoriteTagListView.tagViews[category.index]
            tagView.isSelected = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backBarButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func saveBarButtonTapped(_ sender: Any) {
        viewModel.userSetting.favCategories = selectedCategories
        
        let hud = showActivityHUDTopMost()
        viewModel.updateProfileSettings().subscribe { [weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            switch evt {
            case .next:
                _self.ext_messages.show(type: .success, body: "Succeed to update interesting categories.".localized, vc: nil)
                _ = _self.popViewController()
            case .error(let error):
                print(error.localizedDescription)
                _self.ext_messages.show(type: .error, body: "Failed to update interesting categories.".localized, vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    func initTagListView() {
        favoriteTagListView.alignment = .center
        favoriteTagListView.cornerRadius = 16
        favoriteTagListView.tagBackgroundColor = .clear
        favoriteTagListView.borderWidth = 2
        favoriteTagListView.borderColor = .lightGray
        favoriteTagListView.textColor = .darkGray
        favoriteTagListView.tagSelectedBackgroundColor = .lightGray
        favoriteTagListView.textFont = UIFont.systemFont(ofSize: 20)
        favoriteTagListView.paddingX = 16
        favoriteTagListView.paddingY = 12
        favoriteTagListView.marginX = 8
        favoriteTagListView.marginY = 8
        favoriteTagListView.addTags(Category.all.map { $0.rawValue })
        
        favoriteTagListView.delegate = self
    }
}

extension FavoriteCategoryViewController: TagListViewDelegate {
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        tagView.isSelected = !tagView.isSelected
        
        let category = Category(rawValue: title)!
        if tagView.isSelected {
            selectedCategories.append(category)
        } else {
            let index = selectedCategories.index(of: category)
            selectedCategories.remove(at: index!)
        }
    }
}

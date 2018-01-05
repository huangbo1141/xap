//
//  SideMenuVIewController.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class SideMenuVIewController: UIViewController, MenuDelegate {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userNameDescriptionLabel: UILabel!
    @IBOutlet weak var categoriesTableView: UITableView!
    @IBOutlet weak var categoriesTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var categoryMenuAccessoryImageView: UIImageView!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    var categoriesTableViewHeight = 0

    var easySlideNavigationController: ESNavigationController?
    
    var isCategoriesMenuCollapsed = true {
        didSet {
            categoriesTableViewHeightConstraint.constant = !isCategoriesMenuCollapsed ? CGFloat(categoriesTableViewHeight) : 0
            categoryMenuAccessoryImageView.image = !isCategoriesMenuCollapsed ? #imageLiteral(resourceName: "ic_collapse_light_gray") : #imageLiteral(resourceName: "ic_expand_light_gray")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        categoriesTableView.dataSource = self
        categoriesTableView.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageCount), name: NSNotification.Name("UpdateMessageCount"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isCategoriesMenuCollapsed = true
        
        if AppContext.shared.userCredentials.userId <= 0 || AppContext.shared.currentUser == nil {
            userNameLabel.text = "Create Account or Sign in".localized
            userNameDescriptionLabel.text = "at XAP".localized
        } else {
            userNameLabel.text = AppContext.shared.currentUser!.userName
            userNameDescriptionLabel.text = "Go to profile".localized
            
            let avatarImageUrl = try? APIURL(stringLiteral: AppContext.shared.currentUser!.profileImage).asPhotoURL()
            avatarImageView.kf.setImage(with: avatarImageUrl, placeholder: #imageLiteral(resourceName: "ic_face")) { image, _, _, _ in
                AppContext.shared.currentUser?.avatarImage = image
            }
        }
        
        updateMessageCount()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func chatButtonTapped(_ sender: Any) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .chat)
        }
    }
    
    @IBAction func bulletinButtonTapped(_ sender: Any) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .bulletin)
        }
    }
    
    @IBAction func categoriesButtonTapped(_ sender: Any) {
        isCategoriesMenuCollapsed = !isCategoriesMenuCollapsed
    }
    
    @IBAction func inviteButtonTapped(_ sender: Any) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .invite)
        }
    }
    
    @IBAction func helpButtonTapped(_ sender: Any) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .help)
        }
    }
    
    @IBAction func profileButtonTapped(_ sender: Any) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .profile)
        }
    }
    
    func updateMessageCount() {
        let unReadCount = Message.totalUnReadCount(context: AppContext.shared.mainContext, userId: AppContext.shared.userCredentials.userId)
        unreadCountLabel.text = "\(unReadCount)"
        unreadCountLabel.isHidden = unReadCount == 0
    }
}

extension SideMenuVIewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        categoriesTableViewHeight = 40 * Category.all.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Category.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as CategoryMenuCell
        cell.category = Category.all[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let mainNavVC = easySlideNavigationController as? MainNavigationViewController {
            mainNavVC.sideMenuSelected(menu: .category(Category.all[indexPath.row]))
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

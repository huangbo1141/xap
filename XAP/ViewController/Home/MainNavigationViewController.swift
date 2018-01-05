//
//  MainNavigationViewController.swift
//  XAP
//
//  Created by Alex on 6/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import FBSDKShareKit
import Bolts
import MessageUI

class MainNavigationViewController: ESNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let sideMenuVC = XAPStoryboard.homeScene.sideMenuVC()
        setupMenuViewController(.leftMenu, viewController: sideMenuVC)
        sideMenuVC.easySlideNavigationController = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sideMenuSelected(menu: SideMenu) {
        switch menu {
        case .profile:
            if AppContext.shared.userCredentials.userId <= 0 || AppContext.shared.currentUser == nil {
                let vc = XAPStoryboard.landingScene.landingVC()
                self.modalPresentationStyle = .currentContext
                present(vc, animated: true)
            } else {
                let vc = XAPStoryboard.profileScene.profileVC()
                let user = AppContext.shared.currentUser!
                vc.viewModel = ProfileViewModel(user: user)
                show(vc, sender: nil)
            }
        case .chat:
            if AppContext.shared.userCredentials.userId <= 0 || AppContext.shared.currentUser == nil {
                let vc = XAPStoryboard.landingScene.landingVC()
                self.modalPresentationStyle = .currentContext
                present(vc, animated: true)
            } else {
                let vc = XAPStoryboard.chatScene.chatListVC()
                show(vc, sender: nil)
            }
        case .bulletin:
            let vc = XAPStoryboard.bulletinScene.bulletinVC()
            show(vc, sender: nil)
        case .invite:
            let vc = XAPStoryboard.inviteScene.inviteFriendVC()
            self.modalPresentationStyle = .currentContext
            
            vc.completionHandler = inviteFriend
            
            present(vc, animated: true)
        case .help:
            let vc = XAPStoryboard.helpScene.helpVC()
            show(vc, sender: nil)
        case .category(let category):
            // call api
            let hud = showActivityHUD()
            AppContext.searchItems = [Item]()
//            ItemManager.default.refreshItems(offset: -2)
//                .subscribe { _ in
//                    hud.hide(animated: true)
//                    let vc = XAPStoryboard.searchScene.searchResultVC()
//                    let viewModel = SearchViewModel()
//                    viewModel.category = category
//                    //viewModel.initFilter()
//
//                    viewModel.inputItems = AppContext.searchItems
//                    vc.viewModel = viewModel
//
//                    let navVC = UINavigationController(rootViewController: vc)
//                    navVC.navigationBar.barTintColor = UIColor(hexString: "0F9CFF")
//
//                    self.present(navVC, animated: true)
//
//                    self.closeOpenMenu(animated: true, completion: nil)
//                }.addDisposableTo(self.rx_disposeBag)
            
            ItemManager.default.refreshItemsForCategory(offset: -1,category:category)
                .subscribe { _ in
                    hud.hide(animated: true)
                    let vc = XAPStoryboard.searchScene.searchResultVC()
                    let viewModel = SearchViewModel()
                    viewModel.category = category
                    viewModel.inputItems = AppContext.searchItems
                    vc.viewModel = viewModel

                    let navVC = UINavigationController(rootViewController: vc)
                    navVC.navigationBar.barTintColor = UIColor(hexString: "0F9CFF")

                    self.present(navVC, animated: true)

                    
                }.addDisposableTo(self.rx_disposeBag)
        }
        self.closeOpenMenu(animated: true, completion: nil)
    }
    
    func inviteFriend(_ type: InviteType) {
        switch type {
        case .facebook:
            inviteFriendByFacebook()
        case .email:
            iniviteFriendByMail()
        case .whatsapp:
            inviteFriendByWhatsApp()
        case .other:
            inviteFriendByOther()
        }
    }
    
    func inviteFriendByFacebook() {
        let content = FBSDKAppInviteContent()
        content.appLinkURL = URL(string: "https://fb.me/117976988873892")
        FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
    }
    
    func iniviteFriendByMail() {
        let mailComopserVC = MFMailComposeViewController()
        mailComopserVC.mailComposeDelegate = self
        
//        mailComopserVC.setToRecipients("email")
        mailComopserVC.setSubject("XAP Invitation".localized)
        mailComopserVC.setMessageBody("I've been using XAP, and it's been great. Use it to earn some extra money by selling what you don't need, and discover fantastic things for sale in your community.\n\n".localized, isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            present(mailComopserVC, animated: true)
        }
    }
    
    func inviteFriendByWhatsApp() {
        let urlString = "I've been using XAP, and it's been great. Use it to earn some extra money by selling what you don't need, and discover fantastic things for sale in your community.\n\n".localized
        let urlStringEncoded = urlString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let url = URL(string: "whatsapp://send?text=\(urlStringEncoded!)")
//        let url  = NSURL(string: "whatsapp://send?text=\(urlStringEncoded!)")
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        } else {
            let errorAlert = UIAlertView(title: "Cannot Send Message", message: "Your device is not able to send WhatsApp messages.", delegate: self, cancelButtonTitle: "OK")
            errorAlert.show()
        }
    }
    
    func inviteFriendByOther() {
        let activityViewController = UIActivityViewController(activityItems: ["I've been using XAP, and it's been great. Use it to earn some extra money by selling what you don't need, and discover fantastic things for sale in your community.\n\n".localized], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        activityViewController.excludedActivityTypes = [UIActivityType.airDrop, UIActivityType.postToFacebook, UIActivityType.postToTwitter, UIActivityType.mail, UIActivityType.message, UIActivityType.copyToPasteboard]
        
        self.present(activityViewController, animated: true)
    }
}

extension MainNavigationViewController: FBSDKAppInviteDialogDelegate {
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {
        print("invitation failed")
    }
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {
        print("Invitation made")
    }
}

extension MainNavigationViewController : MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

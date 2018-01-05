//
//  NotificationSettingViewController.swift
//  XAP
//
//  Created by Alex on 17/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class NotificationSettingViewController: UIViewController {

    @IBOutlet weak var chatMessageSwitch: UISwitch!
    @IBOutlet weak var priceChangeSwitch: UISwitch!
    @IBOutlet weak var expiredListingSwitch: UISwitch!
    @IBOutlet weak var promotionsSwitch: UISwitch!
    @IBOutlet weak var tipsSwitch: UISwitch!
    
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        initUI()
    }
    
    func initUI() {
        chatMessageSwitch.isOn = viewModel.userSetting.isNotifyChatMessage
        priceChangeSwitch.isOn = viewModel.userSetting.isNotifyPriceChange
        expiredListingSwitch.isOn = viewModel.userSetting.isNotifyExpiredListing
        promotionsSwitch.isOn = viewModel.userSetting.isNotifyPromotions
        tipsSwitch.isOn = viewModel.userSetting.isNotifyTips
    }
    
    @IBAction func backBarButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let hud = showActivityHUDTopMost()
        viewModel.updateProfileSettings().subscribe { [weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            switch evt {
            case .next:
                _self.ext_messages.show(type: .success, body: "Succeed to update Notification settings.".localized, vc: nil)
                _ = _self.popViewController()
            case .error(let error):
                print(error.localizedDescription)
                _self.ext_messages.show(type: .error, body: "Failed to update Notification settings.".localized, vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    @IBAction func chatMessageSwitchChanged(_ sender: Any) {
        viewModel.userSetting.isNotifyChatMessage = chatMessageSwitch.isOn
    }
    
    @IBAction func priceChangesSwitchChanged(_ sender: Any) {
        viewModel.userSetting.isNotifyPriceChange = priceChangeSwitch.isOn
    }
    
    @IBAction func expiredListingSwitchChanged(_ sender: Any) {
        viewModel.userSetting.isNotifyExpiredListing = expiredListingSwitch.isOn
    }
    
    @IBAction func promotionsSwitchChanged(_ sender: Any) {
        viewModel.userSetting.isNotifyPromotions = promotionsSwitch.isOn
    }
    
    @IBAction func tipsSwitchChanged(_ sender: Any) {
        viewModel.userSetting.isNotifyTips = tipsSwitch.isOn
    }
}

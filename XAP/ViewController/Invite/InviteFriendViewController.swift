//
//  InviteFriendViewController.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

enum InviteType: Int {
    case facebook = 0
    case email = 1
    case whatsapp = 2
    case other = 3
}

class InviteFriendViewController: UIViewController {

    var tableVC: UITableViewController!
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var containerView: UIView!

    var completionHandler : ((InviteType) -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func viewTapped() {
        dismiss(animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, identifier == "segue_invite_contain_sub_viewcontroller" else { return }
        tableVC = segue.destination as! UITableViewController
        tableVC.tableView.delegate = self
    }
}

extension InviteFriendViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        dismiss(animated: true) {
            self.completionHandler?(InviteType(rawValue: indexPath.row) ?? .other)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
}

//
//  ChoosingReasonViewController.swift
//  XAP
//
//  Created by Alex on 17/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class ChoosingReasonViewController: UIViewController {

    @IBOutlet weak var reasonTableView: UITableView!
    
    var completeHandler: ((ReportReason) -> Void)? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        reasonTableView.dataSource = self
        reasonTableView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension ChoosingReasonViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ReportReason.all.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ChoosingReasonTableViewCell
        cell.reason = ReportReason.all[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        completeHandler?(ReportReason.all[indexPath.row])
        dismiss(animated: true)
    }
}

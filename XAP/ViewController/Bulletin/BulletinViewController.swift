//
//  BulletinViewController.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class BulletinViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel = BulletinViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let hud = showActivityHUDTopMost()
        viewModel.getBulletin().subscribe { [weak self] evt in
            hud.hide(animated: true)
            switch evt {
            case .next:
                self?.tableView.reloadData()
            case .error(let error):
                print(error.localizedDescription)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
}

extension BulletinViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bulletin.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as BulletinTableViewCell
        cell.bulletin = viewModel.bulletin[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = XAPStoryboard.bulletinScene.bulletinDetailVC()
        vc.bulletin = viewModel.bulletin[indexPath.row]
        show(vc, sender: nil)
    }
}

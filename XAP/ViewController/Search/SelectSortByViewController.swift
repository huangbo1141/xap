//
//  SelectSortByViewController.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class SelectSortByViewController: UIViewController {

    @IBOutlet weak var sortByListView: UIView!
    
    var selectedSortByHandler: ((SortBy) -> ())?
    
    var sortByListTableViewController :  SortByListTableViewController! {
        didSet {
            sortByListTableViewController.selectSortByHandler = selectedSortBy
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard segue.identifier == "EmbededSortByListSegue" else { return }
        
        sortByListTableViewController = segue.destination as! SortByListTableViewController
    }
    
    func selectedSortBy(_ sortBy: SortBy) {
        selectedSortByHandler?(sortBy)
        dismiss(animated: true)
    }
}

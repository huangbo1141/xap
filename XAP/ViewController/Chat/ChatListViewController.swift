//
//  ChatListViewController.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit

class ChatListViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var deleteBarButton: UIBarButtonItem!
    
    let viewModel = ChattingRoomListViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonTapped(_:)))
        deleteBarButton.tintColor = .white
        navigationItem.rightBarButtonItem = deleteBarButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateMessageCount), name: NSNotification.Name("UpdateMessageCount"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
        
        guard let notifData = AppContext.shared.notifData else { return }
        guard notifData["type"] as! String == "message" else { return }
        
        let itemId = Int(notifData["item_id"] as! String) ?? 0
        let userId = Int(notifData["user_id"] as! String) ?? 0
        
        guard itemId > 0, userId > 0 else { return }
        
        AppContext.shared.notifData = nil
        
        let chattingViewModel = ChattingViewModel(itemId: itemId, userId: userId)
        let vc = ChatViewController(viewModel: chattingViewModel)
        show(vc, sender: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        _ = popViewController()
    }
    
    func deleteBarButtonTapped(_ sender: Any) {
        if tableView.isEditing == true {
            tableView.isEditing =  false
            
            deleteBarButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteBarButtonTapped(_:)))
            deleteBarButton.tintColor = .white
            navigationItem.rightBarButtonItem = deleteBarButton
        } else {
            tableView.isEditing =  true
            
            deleteBarButton = UIBarButtonItem(title: "Done".localized, style: .plain, target: self, action: #selector(deleteBarButtonTapped(_:)))
            deleteBarButton.tintColor = .white
            navigationItem.rightBarButtonItem = deleteBarButton
        }
    }
}

extension ChatListViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatRoomList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath) as ChatListTableViewCell
        cell.chattingRoomLastMessage = viewModel.chatRoomList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var userId = 0
        if viewModel.chatRoomList[indexPath.row].from == AppContext.shared.userCredentials.userId {
            userId = viewModel.chatRoomList[indexPath.row].to
        } else {
            userId = viewModel.chatRoomList[indexPath.row].from
        }
        
        let chattingViewModel = ChattingViewModel(itemId: viewModel.chatRoomList[indexPath.row].itemId, userId: userId)
        let vc = ChatViewController(viewModel: chattingViewModel)
        show(vc, sender: nil)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let hud = showActivityHUDTopMost()
        viewModel.deleteChats(at: indexPath.row).subscribe { [weak self] evt in
            hud.hide(animated: true)
            guard let _self = self else { return }
            switch evt {
            case .next:
                _self.tableView.deleteRows(at: [indexPath], with: .automatic)
            case .error(let error):
                print(error.localizedDescription)
                _self.ext_messages.show(type: .error, body: "Failed to delete messsages.".localized, vc: nil)
            default:
                break
            }
        }.addDisposableTo(rx_disposeBag)
    }
    
    func updateMessageCount() {
        tableView.reloadData()
    }
}

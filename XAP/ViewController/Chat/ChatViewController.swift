//
//  ChatViewController.swift
//  XAP
//
//  Created by Alex on 22/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import RxSwift

class ChatViewController: JSQMessagesViewController {

    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incommingBubbleImageView: JSQMessagesBubbleImage!
    
    var viewModel: ChattingViewModel!

    var loadedCells = [(String, WeakBox<JSQMessagesCollectionViewCell>)]()
    
    fileprivate var isAtBottomOfMessages = false
    
    var timer: Timer? = nil
    
    init(viewModel: ChattingViewModel) {
        super.init(nibName: nil, bundle: nil)
        self.senderId = "\(AppContext.shared.currentUser!.id)"
        
        guard Item.arrangedItems(context: AppContext.shared.mainContext) else { return }
        
        self.viewModel = viewModel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout.incomingAvatarViewSize = viewModel.incomingAvatarSize
        collectionView.collectionViewLayout.outgoingAvatarViewSize = viewModel.outgoingAvatarSize
        
        viewModel.changesCallback = { [weak self] signal in
            guard let collectionView = self?.collectionView else { return }
            signal.apply(to: collectionView, cellUpdater: { [weak self] (cell: JSQMessagesCollectionViewCell, indexPath, message) in
                self?.setupCell(cell: cell, indexPath: indexPath, message: message)
            })
        }
        
        Message.readMessages(context: AppContext.shared.mainContext, from: viewModel.userId, to: AppContext.shared.userCredentials.userId, itemId: viewModel.itemId)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = "Chat".localized
        
        navigationController?.isNavigationBarHidden = false
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "ic_back_arrow_white"), style: .plain, target: self, action: #selector(backButtonTapped))
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        // Remove "Attach" button on inputToolbar
        self.inputToolbar.contentView.leftBarButtonItem = nil
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func backButtonTapped() {
        _ = popViewController()
    }
}

// MARK: - JSQMessagesViewController overrides
extension ChatViewController {
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
//        finishSendingMessage()
        viewModel.sendChat(message: text).subscribe { [weak self] _ in
            self?.finishSendingMessage()
        }.addDisposableTo(rx_disposeBag)
    }
    
    func isOutgoingMessage(_ messageItem: JSQMessageData!) -> Bool {
        return viewModel.isOutgoingMessage(messageItem)
    }
}

// MARK: - CollectionView overrides
extension ChatViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = viewModel.messages[indexPath.item]
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        setupCell(cell: cell, indexPath: indexPath, message: message)
        
        return cell
    }
    
    func setupCell(cell: JSQMessagesCollectionViewCell, indexPath: IndexPath, message: Message) {
        if !isOutgoingMessage(message) {
            loadedCells.append((message.senderId(), WeakBox(value: cell)))
        }
        
        loadedCells = loadedCells.filter { $0.1.value != nil }
        cell.textView.textColor = .black
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.messages.count - 1 {
            isAtBottomOfMessages = false
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.item == viewModel.messages.count - 1 {
            isAtBottomOfMessages = true
        }
    }
}

// MARK: - CollectionView Delegate FlowLayout Cell Heights
extension ChatViewController {
    /// Messages Big timestamp display
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return viewModel.shouldDisplayTimestamp(at: indexPath.row) ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        // Display name or not?
        return viewModel.shouldDisplaySenderNameAndAvatar(at: indexPath.row) ? kJSQMessagesCollectionViewCellLabelHeightDefault : 0
    }
}

extension ChatViewController {
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, didTapMessageBubbleAt indexPath: IndexPath!) {
        
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return viewModel.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = viewModel.messages[indexPath.item]
        return viewModel.bubbleImage(for: message)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let row = indexPath.item
        guard viewModel.shouldDisplayTimestamp(at: row) else  { return nil }
        let message = viewModel.messages[row]
        return JSQMessagesTimestampFormatter.shared().attributedTimestamp(for: message.timestamp)
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        let row = indexPath.item
        guard viewModel.shouldDisplaySenderNameAndAvatar(at: row) else { return nil }
        return NSAttributedString(string: viewModel.inComingMessageSenderDisplayName(at: row) ?? "")
    }
    /*
     override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
     
     }*/
}

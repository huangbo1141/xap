//
//  ChattingViewModel.swift
//  XAP
//
//  Created by Alex on 22/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import Chameleon

class ChattingViewModel: ChattingModel {
    
    override init(itemId: Int, userId: Int) {
        super.init(itemId: itemId, userId: userId)
    }
    
    // MARK: - Additional configs
    lazy var bubbleFactory:JSQMessagesBubbleImageFactory = {
        return JSQMessagesBubbleImageFactory()
    }()
    
    lazy var outgoingBubbleImageData:JSQMessageBubbleImageDataSource = {[unowned self] _ in
        return self.bubbleFactory.outgoingMessagesBubbleImage(with: .flatSkyBlue())
        }()
    
    lazy var incomingBubbleImageData:JSQMessageBubbleImageDataSource = {[unowned self] _ in
        return self.bubbleFactory.incomingMessagesBubbleImage(with: .flatSand())
        }()
    
    typealias AvatarFactory = JSQMessagesAvatarImageFactory
    let avatarImageSize = kJSQMessagesCollectionViewAvatarSizeDefault
    
    func bubbleImage(for message:JSQMessageData) -> JSQMessageBubbleImageDataSource{
        if isOutgoingMessage(message){
            return outgoingBubbleImageData
        }
        return incomingBubbleImageData
    }
    
    func isOutgoingMessage(_ message:JSQMessageData) -> Bool{
        return "\(AppContext.shared.userCredentials.userId)" == message.senderId()
    }
    
    //    let incomingAvatarSize = CGSize(width: kJSQMessagesCollectionViewAvatarSizeDefault, height: kJSQMessagesCollectionViewAvatarSizeDefault)
    let incomingAvatarSize = CGSize.zero
    let outgoingAvatarSize = CGSize.zero
    
    
    // MARK: - Avatar Image manage
    // Ids for caching in progress avatars.
    var accountsInAvatarProcess = [String]() // In process account ids
    var avatarImages = [String:JSQMessagesAvatarImage]() // This is good as dimension is 30x30
    var avatarInfos = [String:(JSQMessagesAvatarImage, String)]()   // (Image, Display Name) pair of avatar infos
    
    var refreshAvatarCallback:((String) -> Void)?
    
    func inComingMessageSenderDisplayName(at index:Int) -> String?{
        guard index < messages.count else { return nil }
        let message = messages[index]
        guard !isOutgoingMessage(message) else { return nil }
        
        return message.senderDisplayName()
    }
    
    let timestampDisplayInterval = TimeInterval(180)    // display timestamp if difference with preview message is 3 minutes.
    func shouldDisplayTimestamp(at index: Int) -> Bool {
        /**
         Calculate difference from last message received.
         */
        guard index < messages.count else { return false }
        guard index > 0 else { return true }
        
        let prevMessage = messages[index - 1]
        let message = messages[index]
        
        let interval = message.timestamp.timeIntervalSince(prevMessage.timestamp)
        return interval > timestampDisplayInterval
    }
    
    func shouldDisplaySenderNameAndAvatar(at index: Int) -> Bool {
        guard index < messages.count else { return false }
        let message = messages[index]
        
        // Don't display name on out going message
        guard !isOutgoingMessage(message) else { return false }
        guard index > 0 else { return false }
        
        let prevMessage = messages[index - 1]
        if prevMessage.senderId() != message.senderId() {
            return true
        }
        return shouldDisplayTimestamp(at: index)
    }

    func sendChat(message: String) -> Observable<()> {
        return APIManager.default.sendChat(itemId: itemId,
                                           fromId: AppContext.shared.currentUser!.id,
                                           toId: userId,
                                           message: message)
            .map {
                let _ = try? Message.createMessage(in: AppContext.shared.mainContext, json: $0)
        }
    }
}

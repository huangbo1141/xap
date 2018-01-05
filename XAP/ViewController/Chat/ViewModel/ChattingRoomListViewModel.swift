//
//  ChattingRoomListViewModel.swift
//  XAP
//
//  Created by Alex on 23/9/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import Foundation
import CoreDataStack
import RxSwift

class ChattingRoomListViewModel {
    
    var chatRoomList: [Message] = []    /// Every chatting room's last message
    
    init() {
        upgradeChattingRoom()
    }
    
    func upgradeChattingRoom() {
        guard let messages = try? AppContext.shared.mainContext.fetch(Message.fetchAllRequestByDescendingSort()) else { return }
        chatRoomList = messages.removeDuplicates { (msg1, msg2) -> Bool in
            guard msg1.itemId == msg2.itemId else { return false }
            if msg1.from == msg2.from, msg1.to == msg2.to {
                return true
            }
            if msg1.from == msg2.to, msg1.to == msg2.from {
                return true
            }
            return false
        }
    }
    
    func deleteChats(at index: Int) -> Observable<()> {
        let message = chatRoomList[index]
        guard let messages = try? AppContext.shared.mainContext.fetch(Message.fetchRequest(itemId: message.itemId,
                                                                                           user1: message.from,
                                                                                           user2: message.to)) else { return Observable.just() }
        let messageIds = messages.map { "\($0.id)" }.joined(separator: ",")
        messages.forEach {
            AppContext.shared.mainContext.delete($0)
        }
        
        chatRoomList.remove(at: index)
        return APIManager.default.deleteChats(ids: messageIds)
    }
}

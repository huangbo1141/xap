//
//  ChatListTableViewCell.swift
//  XAP
//
//  Created by Alex on 16/8/2017.
//  Copyright © 2017 alex. All rights reserved.
//

import UIKit
import Kingfisher

class ChatListTableViewCell: UITableViewCell {

    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var itemNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    var chattingRoomLastMessage: Message! {
        didSet {
            let pictureUrl = try? APIURL(stringLiteral: chattingRoomLastMessage.item?.pictureUrls[0] ?? "").asPhotoURL()
            itemImageView.kf.setImage(with: pictureUrl, placeholder: #imageLiteral(resourceName: "item_placeholder"))
            itemNameLabel.text = chattingRoomLastMessage.item?.title
            
            var clientId = 0
            if chattingRoomLastMessage.from == AppContext.shared.userCredentials.userId {
                userNameLabel.text = chattingRoomLastMessage.toUserName
                clientId = chattingRoomLastMessage.to
            } else {
                userNameLabel.text = chattingRoomLastMessage.fromUserName
                clientId = chattingRoomLastMessage.from
            }
            lastMessageLabel.text = chattingRoomLastMessage.message
            dateLabel.text = chattingRoomLastMessage.timestamp.toDateString(format: "MM/dd/yyyy HH:mm")
            
            let unreadCount = Message.getUnReadCount(context: AppContext.shared.mainContext,
                                                     from: clientId,
                                                     to: AppContext.shared.userCredentials.userId,
                                                     itemId: chattingRoomLastMessage.itemId)
            unreadCountLabel.text = "\(unreadCount)"
            unreadCountLabel.isHidden = unreadCount == 0
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

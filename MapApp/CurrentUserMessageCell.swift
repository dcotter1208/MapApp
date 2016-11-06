//
//  CurrentUserMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/21/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class CurrentUserMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!

    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        let profileImage = #imageLiteral(resourceName: "current_user")
        let messageTuple = (message: message, user: User(name: "Current User", location: "Detroit, MI", userID: CurrentUser.sharedInstance.userID, profileImageURL: "", profileImage: profileImage))
        DispatchQueue.main.async {
            self.messageTextView.layer.cornerRadius = 10
            self.messageTextView.backgroundColor = UIColor.blue
            self.messageTextView.textColor = UIColor.white
            self.messageTextView.text = messageTuple.message.message
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
            self.profileImageView.layer.masksToBounds = true
            if let profileImage = messageTuple.user.profileImage {
                self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage)
            }
        }
    }
    
    fileprivate func setProfileImageWithResizedImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/5, height: image.size.width/5)
        return image.resizedImage(newSize)
    }

}

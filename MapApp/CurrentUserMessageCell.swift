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
    
    let profileImageCacheIdentifier = "currentUserProfileImage"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        var profileImage: UIImage
        profileImage = setMessageProfileImageForCurrentUser()
        let currentUser = CurrentUser.sharedInstance
        let messageTuple = (message: message, user: User(name: currentUser.name, location: currentUser.location, userID: currentUser.userID, profileImageURL: currentUser.profileImageURL, profileImage: profileImage))
        self.messageTextView.text = messageTuple.message.text
        DispatchQueue.main.async {
            self.configureMessageTextView()
            self.profileImageView.image = messageTuple.user.profileImage
            self.configureProfileImageView()
        }
    }
    
    //MARK: Cell Attribute Helper Methods

    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.backgroundColor = UIColor.blue
        self.messageTextView.textColor = UIColor.white
    }
    
    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func resizeProfileImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width / 5, height: image.size.width / 5)
        return image.resizedImage(newSize)
    }

    fileprivate func setMessageProfileImageForCurrentUser() -> UIImage {
        var profileImage: UIImage
        if CurrentUser.sharedInstance.profileImage != nil {
            profileImage = resizeProfileImage(image: CurrentUser.sharedInstance.profileImage!)
        } else {
            profileImage = #imageLiteral(resourceName: "default_user")
        }
        return profileImage
    }

}

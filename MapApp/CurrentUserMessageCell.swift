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
    
    var messageTuple: (message: Message, currentUser: CurrentUser)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        setMessageProfileImageForCurrentUser()
        
        messageTuple = (message: message, currentUser: CurrentUser.sharedInstance)
        
        self.messageTextView.text = messageTuple?.message.text
        DispatchQueue.main.async {
            self.configureMessageTextView()
        }
    }
    
    //MARK: Cell Attribute Helper Methods

    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.backgroundColor = UIColor.blue
        self.messageTextView.textColor = UIColor.white
        self.messageTextView.sizeToFit()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.image = nil

        self.messageTextView.text = nil
        self.messageTextView.sizeToFit()
    }
    
    fileprivate func setProfileImageWithResizedImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/5, height: image.size.width/5)
        return image.resizedImage(newSize)
    }
    
    fileprivate func setMessageProfileImageForCurrentUser() {
        if CurrentUser.sharedInstance.profileImage == nil {
            messageTuple?.currentUser.profileImage = #imageLiteral(resourceName: "default_user")
        }
        DispatchQueue.main.async {
            self.profileImageView.image = self.messageTuple?.currentUser.profileImage
        }
    }
    
}

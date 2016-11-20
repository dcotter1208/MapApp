//
//  DefaultMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/21/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class DefaultMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        let profileImage = #imageLiteral(resourceName: "bill_murray_ghost")
        let messageTuple = (message: message, user: User(name: "Scrooged", location: "NY, NY", userID: "123", profileImageURL: "", profileImage: profileImage))
        messageTextView.text = messageTuple.message.text
        DispatchQueue.main.async {
            self.configureMessageTextView()
            self.configureProfileImageView()
            if let profileImage = messageTuple.user.profileImage {
                self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage)
            }
        }
    }
    
    //MARK: Cell Attribute Helper Methods
    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.backgroundColor = UIColor.lightGray
        self.messageTextView.textColor = UIColor.black
    }

    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func setProfileImageWithResizedImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/5, height: image.size.width/5)
        return image.resizedImage(newSize)
    }
    
}

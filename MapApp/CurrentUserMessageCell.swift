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
        DispatchQueue.main.async {
            self.messageTextView.layer.cornerRadius = 10
            self.messageTextView.backgroundColor = UIColor.blue
            self.messageTextView.textColor = UIColor.white
            self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height/2
            self.profileImageView.layer.masksToBounds = true
//            if let profileImage = message.user.profileImage {
                self.profileImageView.image = self.setProfileImageWithResizedImage(image: #imageLiteral(resourceName: "current_user"))
//            }
        }
    }
    
    fileprivate func setProfileImageWithResizedImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/5, height: image.size.width/5)
        return image.resizedImage(newSize)
    }

}

//
//  DefaultMediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/19/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class DefaultMediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellViewAttributesWithMessage(message: Message) {
        var profileImage: UIImage
        if CurrentUser.sharedInstance.profileImage != nil {
            profileImage = CurrentUser.sharedInstance.profileImage!
        } else {
            profileImage = #imageLiteral(resourceName: "default_user")
        }
        let messageTuple = (message: message, user: User(name: "Current User", location: "Detroit, MI", userID: CurrentUser.sharedInstance.userID, profileImageURL: "", profileImage: profileImage))
        self.profileImageView.image = messageTuple.user.profileImage
        
        DispatchQueue.main.async {
            if let mediaURL = message.mediaURL, let profileImage = messageTuple.user.profileImage {
                self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage)
                self.configureMediaImageView()
                self.configureProfileImageView()
                AlamoFireOperation.downloadProfileImageWithAlamoFire(URL: mediaURL,
                 completion: { (image, error) in
                    self.mediaImageView.image = image
                })
            }
        }
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
        self.mediaImageView.layer.shadowColor = UIColor.black.cgColor
        self.mediaImageView.layer.borderColor = UIColor.lightGray.cgColor
        self.mediaImageView.layer.backgroundColor = UIColor.blue.cgColor
        self.mediaImageView.layer.borderWidth = 5
    }
    
    fileprivate func configureProfileImageView() {
        let profileImage = #imageLiteral(resourceName: "bill_murray_scrooged")
        self.profileImageView.image = profileImage
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func setProfileImageWithResizedImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width/5, height: image.size.width/5)
        return image.resizedImage(newSize)
    }

}

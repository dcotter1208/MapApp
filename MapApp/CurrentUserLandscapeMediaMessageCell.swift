//
//  CurrentUserLandscapeMediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 12/16/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class CurrentUserLandscapeMediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!

    var messageTuple: (media: UIImage?, user: CurrentUser?)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        messageTuple = (nil, CurrentUser.sharedInstance)
        setMessageProfileImageForCurrentUser()
        if let URLString = message.mediaURL {
            downloadMediaForCellImageView(mediaURL: URLString)
        }
        DispatchQueue.main.async {
            self.configureMediaImageView()
            self.configureProfileImageView()
        }
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.clipsToBounds = true
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
    }
    
    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func resizeProfileImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width / 5, height: image.size.width / 5)
        return image.resizedImage(newSize)
    }
    
    fileprivate func setMessageProfileImageForCurrentUser() {
        if CurrentUser.sharedInstance.profileImage == nil {
            messageTuple.user?.profileImage = #imageLiteral(resourceName: "default_user")
        }
        self.profileImageView.image = messageTuple.user?.profileImage
    }
    
    fileprivate func downloadMediaForCellImageView(mediaURL: String) {
        if let url = URL(string: mediaURL) {
            self.mediaImageView.downloadAFImage(url: url)
        }
    }
    //END
}

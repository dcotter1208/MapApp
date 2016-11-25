//
//  CurrentUserMediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/19/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CurrentUserMediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!

    let imageCacher = ImageCacher()
    let profileImageCacheIdentifier = "currentUserProfileImage"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        self.mediaImageView.image = #imageLiteral(resourceName: "placeholder")
        setMessageProfileImageForCurrentUser()
        self.configureMediaImageView()
        self.configureProfileImageView()
        loadMediaForMessage(message: message)
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
    }
    
    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func resizeProfileImage(image: UIImage) -> UIImage {
        let newSize = CGSize(width: image.size.width / 5, height: image.size.width / 5)
        return image.resizedImage(newSize)
    }
    
    fileprivate func setMessageProfileImageForCurrentUser() {
        var profileImage: UIImage
        if CurrentUser.sharedInstance.profileImage != nil {
            profileImage = resizeProfileImage(image: CurrentUser.sharedInstance.profileImage!)
        } else {
            profileImage = #imageLiteral(resourceName: "default_user")
        }
        
        if let cachedImage = imageCacher.retrieveImageFromCache(cacheIdentifier: profileImageCacheIdentifier) {
            self.profileImageView.image = cachedImage
        } else {
            imageCacher.addImageToCache(image: profileImage, cacheIdentifier: profileImageCacheIdentifier)
            self.profileImageView.image = profileImage
        }
    }
    
    fileprivate func loadMediaForMessage(message: Message) {
        if let mediaURL = message.mediaURL {
            if let cachedImage = imageCacher.retrieveImageFromCache(cacheIdentifier: mediaURL) {
                self.mediaImageView.image = cachedImage
                return
            }
            Alamofire.request(mediaURL).responseImage { response in
                if let image = response.result.value {
                    self.mediaImageView.image = image
                    self.imageCacher.addImageToCache(image: image, cacheIdentifier: mediaURL)
                }
            }
        }
    }
}

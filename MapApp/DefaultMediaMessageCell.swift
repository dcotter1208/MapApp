//
//  DefaultMediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/19/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DefaultMediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    let photoCache = AutoPurgingImageCache(
        memoryCapacity: 400 * 1024 * 1024,
        preferredMemoryUsageAfterPurge: 60 * 1024 * 1024)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellViewAttributesWithMessage(message: Message) {
        
        //****NEED TO CACHE PROFILE IMAGES OF SENDERS TO INCREASE SPEED//*****
        
//        var profileImage: UIImage
//        if senders profile image != nil {
//            profileImage = senders profile image
//        } else {
//            profileImage = #imageLiteral(resourceName: "default_user")
//        }
        
//        self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage)
        self.configureMediaImageView()
        self.configureProfileImageView()
        
        loadMediaForMessage(message: message)
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
        self.mediaImageView.layer.shadowColor = UIColor.black.cgColor
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
    
    fileprivate func loadMediaForMessage(message: Message) {
        if let mediaURL = message.mediaURL {
            if let cachedImage = getCachedImage(cacheIdentifier: mediaURL) {
                self.mediaImageView.image = cachedImage
                return
            }
            Alamofire.request(mediaURL).responseImage { response in
                if let image = response.result.value {
                    self.mediaImageView.image = image
                    self.cacheImage(image: image, cacheIdentifier: mediaURL)
                }
            }
        }
    }
    
    fileprivate func cacheImage(image: UIImage, cacheIdentifier: String) {
        photoCache.add(image, withIdentifier: cacheIdentifier)
    }
    
    fileprivate func getCachedImage(cacheIdentifier: String) -> UIImage? {
        if let image = photoCache.image(withIdentifier: cacheIdentifier) {
            return image
        }
        return nil
    }

}

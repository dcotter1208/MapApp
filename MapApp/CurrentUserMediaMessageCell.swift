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

    typealias FirebaseUserProfileResult = (User) -> Void
    let firebaseOp = FirebaseOperation()
    let imageCacher = ImageCacher()
    var messageTuple: (media: UIImage?, user: CurrentUser?)
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        messageTuple = (nil, CurrentUser.sharedInstance)
        setMessageProfileImageForCurrentUser()
        self.configureMediaImageView()
        self.configureProfileImageView()
//        loadMediaForMessage(message: message)
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
        if CurrentUser.sharedInstance.profileImage == nil {
            messageTuple.user?.profileImage = #imageLiteral(resourceName: "default_user")
        }
        self.profileImageView.image = messageTuple.user?.profileImage
    }
    
    fileprivate func loadMediaForMessage(message: Message) {
            if let mediaURL = message.mediaURL {
                if let cachedImage = imageCacher.retrieveImageFromCache(cacheIdentifier: mediaURL) {
                    messageTuple.media = cachedImage
                    DispatchQueue.main.async {
                        self.mediaImageView.image = cachedImage
                    }
                    return
                }
                
                Alamofire.request(mediaURL).responseImage { response in
                    if let image = response.result.value {
                        self.messageTuple.media = image
                        DispatchQueue.main.async {
                            self.mediaImageView.image = image
                        }
                        self.imageCacher.addImageToCache(image: image, cacheIdentifier: mediaURL)
                        return
                    }
                }
            }
        }

}

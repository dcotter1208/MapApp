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
    
    typealias FirebaseUserProfileResult = (User) -> Void
    let defaultProfileImageCacheIdentifer = "defaultProfileImage"
    let firebaseOp = FirebaseOperation()
    let imageCacher = ImageCacher()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellViewAttributesWithMessage(message: Message) {
        
        //****NEED TO CACHE PROFILE IMAGES OF SENDERS TO INCREASE SPEED//*****
        
        var profileImage: UIImage?

        //Cache Image with sender userID

        getUserProfileForMessage(message: message, completion: { (user) in
            if user.profileImage != nil {
                profileImage = user.profileImage!
                self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage!)
            } else {
                profileImage = #imageLiteral(resourceName: "default_user")
                self.profileImageView.image = profileImage
            }
        })
        loadMediaForMessage(message: message)
        configureMediaImageView()
        configureProfileImageView()
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
        self.mediaImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func configureProfileImageView() {
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
    
    fileprivate func getUserProfileForMessage(message: Message, completion: @escaping FirebaseUserProfileResult) {
        let userProfileQuery = firebaseOp.firebaseDatabaseRef.ref.child("users").queryOrdered(byChild: "userID").queryEqual(toValue: message.userID)
        
        firebaseOp.queryChildWithConstraints(userProfileQuery, firebaseDataEventType: .value, observeSingleEventType: true, completion: { (snapshot) in
            if snapshot.exists() {
                User.createUserWithFirebaseSnapshot(snapshot, completion: { (user) in
                    print("created user from snapshot: \(user)")
                    completion(user)
                })
            }
        })
        
    }
    
    

}

//
//  DefaultPortraitMediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/19/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class DefaultPortraitMediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    typealias FirebaseUserProfileResult = (User) -> Void
    
    let firebaseOp = FirebaseOperation()
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func setCellViewAttributesWithMessage(message: Message) {
        getUserProfileForMessage(message: message, completion: { (user) in
            self.setUserProfileImageForMessage(user: user)
        })
        
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
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
    }
    
    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.layer.masksToBounds = true
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }
    
    fileprivate func downloadMediaForCellImageView(mediaURL: String) {
        if let url = URL(string: mediaURL) {
            self.mediaImageView.downloadAFImage(url: url)
        }
    }
    
    fileprivate func setUserProfileImageForMessage(user: User) {
        guard user.profileImageURL != "" else {
            self.profileImageView.image = #imageLiteral(resourceName: "default_user")
            return
        }
        guard let profileURL = URL(string: user.profileImageURL) else {
            self.profileImageView.image = #imageLiteral(resourceName: "default_user")
            return
        }
        self.profileImageView.downloadAFImage(url: profileURL)
    }

    fileprivate func getUserProfileForMessage(message: Message, completion: @escaping FirebaseUserProfileResult) {
        let userProfileQuery = firebaseOp.firebaseDatabaseRef.ref.child("users").queryOrdered(byChild: "userID").queryEqual(toValue: message.userID)
        
        firebaseOp.queryChildWithConstraints(userProfileQuery, firebaseDataEventType: .value, observeSingleEventType: true, completion: {
            (snapshot) in
            if snapshot.exists() {
                User.createUserWithFirebaseSnapshot(snapshot, completion: {
                    (user) in
                    completion(user)
                })
            }
        })
    }
    
    

}

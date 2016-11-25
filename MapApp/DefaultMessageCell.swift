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
    
    typealias FirebaseUserProfileResult = (User) -> Void
    let firebaseOp = FirebaseOperation()

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        var profileImage: UIImage?
        var messageTuple: (message: Message?, user: User?)

        getUserProfileForMessage(message: message, completion: { (user) in
            profileImage = self.setProfileImageForUser(user: user)
            messageTuple = (message: message, user: User(name: user.name, location: user.location, userID: user.userID, profileImageURL: user.profileImageURL, profileImage: profileImage))
            self.messageTextView.text = messageTuple.message?.text
            DispatchQueue.main.async {
                self.configureMessageTextView()
                self.profileImageView.image = messageTuple.user?.profileImage
                self.configureProfileImageView()
            }
        })
    }
    
    //MARK: Cell Attribute Helper Methods
    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.backgroundColor = UIColor.lightGray
        self.messageTextView.textColor = UIColor.black
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

    fileprivate func getUserProfileForMessage(message: Message, completion: @escaping FirebaseUserProfileResult) {
        let userProfileQuery = firebaseOp.firebaseDatabaseRef.ref.child("users").queryOrdered(byChild: "userID").queryEqual(toValue: message.userID)
        firebaseOp.queryChildWithConstraints(userProfileQuery, firebaseDataEventType: .value, observeSingleEventType: true, completion: { (snapshot) in
            if snapshot.exists() {
                User.createUserWithFirebaseSnapshot(snapshot, completion: { (user) in
                    completion(user)
                })
            }
        })
    }
    
    fileprivate func setProfileImageForUser(user: User) -> UIImage {
        var profileImage: UIImage
        if user.profileImage != nil {
            profileImage = user.profileImage!
            self.profileImageView.image = self.resizeProfileImage(image: profileImage)
        } else {
            profileImage = #imageLiteral(resourceName: "default_user")
            self.profileImageView.image = profileImage
        }
        return profileImage
    }
    
}

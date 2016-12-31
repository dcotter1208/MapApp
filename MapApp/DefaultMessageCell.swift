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
        var messageTuple = (message: message, user: User(username: "", userID: "", profileImageURL: "", profileImage: nil))

        getUserProfileForMessage(message: message, completion: {
            (user) in
            messageTuple.user = user
            self.setUserProfileImageForMessage(user: messageTuple.user)
        })
        
        DispatchQueue.main.async {
            self.messageTextView.text = messageTuple.message.text
            self.configureMessageTextView()
        }
    }
    
    //MARK: Cell Attribute Helper Methods
    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
        self.messageTextView.backgroundColor = UIColor.lightGray
        self.messageTextView.textColor = UIColor.black
    }

    fileprivate func setUserProfileImageForMessage(user: User) {
//        self.profileImageView.image = nil
        guard user.profileImageURL != "" else {
            self.profileImageView.image = #imageLiteral(resourceName: "default_user")
            return
        }
        guard let profileURL = URL(string: user.profileImageURL) else { return }
        self.profileImageView.af_setImage(withURL: profileURL, placeholderImage: #imageLiteral(resourceName: "default_user"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: true) { (data) in
            
        }
//        self.profileImageView.downloadAFImage(url: profileURL)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.profileImageView.af_cancelImageRequest()
        self.profileImageView.layer.removeAllAnimations()
        self.profileImageView.image = nil
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

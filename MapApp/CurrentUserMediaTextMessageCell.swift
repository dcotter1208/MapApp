//
//  CurrentUserMediaTextMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/27/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit
import Alamofire
import AlamofireImage

class CurrentUserMediaTextMessageCell: UITableViewCell {
    
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var messageTextView: UITextView!
    
    var messageTuple: (media: UIImage?, message: Message?, user: CurrentUser?)
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        messageTuple = (nil, message, CurrentUser.sharedInstance)
        setMessageProfileImageForCurrentUser()
        if let URLString = message.mediaURL {
            downloadMediaForCellImageView(mediaURL: URLString)
        }
        DispatchQueue.main.async {
            self.messageTextView.text = self.messageTuple.message?.text
            self.configureMessageTextView()
            self.configureMediaImageView()
            self.configureProfileImageView()
        }
    }
    
    fileprivate func configureMessageTextView() {
        self.messageTextView.layer.cornerRadius = 5
    }

    fileprivate func configureMediaImageView() {
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
            self.mediaImageView.af_setImage(withURL: url, placeholderImage: #imageLiteral(resourceName: "placeholder"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .noTransition, runImageTransitionIfCached: false, completion: { (data) in
            })
        }
    }
    
}

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
        
        self.profileImageView.image = self.setProfileImageWithResizedImage(image: profileImage)
        self.configureMediaImageView()
        self.configureProfileImageView()
        
        if let mediaURL = message.mediaURL {
            let url = URL(string: mediaURL)
            self.mediaImageView.af_setImage(withURL: url!, placeholderImage: #imageLiteral(resourceName: "placeholder"), filter: nil, progress: nil, progressQueue: DispatchQueue.main, imageTransition: .crossDissolve(0.50), runImageTransitionIfCached: false, completion: nil)
        }
    }
    
    //MARK: Cell Attribute Helper Methods
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.masksToBounds = true
        self.mediaImageView.layer.shadowColor = UIColor.black.cgColor
        self.mediaImageView.layer.borderColor = UIColor.blue.cgColor
        self.mediaImageView.layer.backgroundColor = UIColor.blue.cgColor
        self.mediaImageView.layer.borderWidth = 5
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

}

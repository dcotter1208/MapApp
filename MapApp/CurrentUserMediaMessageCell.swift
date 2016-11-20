//
//  MediaMessageCell.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/19/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import UIKit

class MediaMessageCell: UITableViewCell, MessageCellProtocol {
    @IBOutlet weak var mediaImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCellViewAttributesWithMessage(message: Message) {
        DispatchQueue.main.async {
            if let mediaURL = message.mediaURL {
                AlamoFireOperation.downloadProfileImageWithAlamoFire(URL: mediaURL,
                    completion: { (image, error) in
                        self.mediaImageView.image = image
                                                                        
                })
            }
            self.configureMediaImageView()
            self.configureProfileImageView()
        }
    }
    
    fileprivate func configureMediaImageView() {
        self.mediaImageView.layer.cornerRadius = 10
        self.mediaImageView.layer.shadowColor = UIColor.black.cgColor
        self.mediaImageView.layer.borderColor = UIColor.blue.cgColor
        self.mediaImageView.layer.borderWidth = 5
    }
    
    fileprivate func configureProfileImageView() {
        self.profileImageView.layer.cornerRadius = self.profileImageView.frame.size.height / 2
        self.profileImageView.layer.shadowColor = UIColor.black.cgColor
    }

}

//
//  User.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import FirebaseDatabase

import UIKit

class User {
    var name: String?
    var location: String?
    var userID: String?
    var imageURL: String?
    var profileImage: UIImage?
    
    func setUserProperties(snapshot:FIRDataSnapshot) {
        for child in snapshot.children {
            guard let
            name = child.value["name"] as? String,
            imageURL = child.value["profilePhotoURL"] as? String,
            userID = child.value["userID"] as? String,
            location = child.value["location"] as? String else {
                return
        }
            self.name = name
            self.location = location
            self.userID = userID
            self.imageURL = imageURL
    }
        guard self.imageURL != "" else {return}
        downloadUserProfileImage(self.imageURL!)
    }
    
    private func downloadUserProfileImage(URL: String) {
        AlamoFireOperation.downloadProfileImageWithAlamoFire(URL) {
            (image, error) in
            guard let image = image else {
                print(error)
                return
            }
            self.profileImage = image
        }
    }
    
    
}

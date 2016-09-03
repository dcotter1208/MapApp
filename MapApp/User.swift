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
    var email: String?
    var location: String?
    var userID: String?
    var imageURL: String?
    var profileImage: UIImage?
    
    //CHECK FOR EDGE CASE FOR snapshot not being an array.
    
    func setUserProperties(snapshot:FIRDataSnapshot) {
        for child in snapshot.children {
            guard let
            name = child.value["name"] as? String,
            email = child.value["email"] as? String,
            imageURL = child.value["profilePhotoURL"] as? String,
            userID = child.value["userID"] as? String,
            location = child.value["location"] as? String else {
                return
        }
            self.name = name
            self.email = email
            self.location = location
            self.userID = userID
            self.imageURL = imageURL
    }
        guard self.imageURL != "" else {return}
        downloadUserProfileImage(self.imageURL!)
    }
    
    func downloadUserProfileImage(URL: String) {
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

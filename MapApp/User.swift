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

typealias ImageResult = (UIImage?, ErrorType?) -> Void
typealias UserResult = (User) -> Void

struct User: UserType {
    var name: String
    var location: String
    var userID: String
    var profileImageURL: String
    var profileImage: UIImage?
  
    func createUser(withSnapshot snapshot:FIRDataSnapshot, completion: UserResult) {
        for child in snapshot.children {
            guard let
                name = child.value["name"] as? String,
                profileImageURL = child.value["profilePhotoURL"] as? String,
                userID = child.value["userID"] as? String,
                location = child.value["location"] as? String else { return }
            
            guard profileImageURL != "" else {
                completion(User(name: name, location: location, userID: userID, profileImageURL: profileImageURL, profileImage: nil))
                return
            }
            
            downloadUserProfileImage(profileImageURL, completion: {
                (image, error) in
                completion(User(name: name, location: location, userID: userID, profileImageURL: profileImageURL, profileImage: image))
            })
        }
    }
}

    private func downloadUserProfileImage(URL: String, completion: ImageResult) {
        AlamoFireOperation.downloadProfileImageWithAlamoFire(URL) {
            (image, error) in
            guard let image = image else {
                completion(nil, error)
                return
            }
            completion(image, nil)
        }
    }
    
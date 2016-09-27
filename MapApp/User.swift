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

typealias ImageResult = (UIImage?, Error?) -> Void
typealias UserResult = (User) -> Void

struct User: UserType {
    var name: String
    var location: String
    var userID: String
    var profileImageURL: String
    var profileImage: UIImage?
  
    func createUserWithFirebaseSnapshot(_ snapshot:FIRDataSnapshot, completion: @escaping UserResult) {
        let snapshotDict = snapshot.value as! NSDictionary
        for child in snapshotDict {
            let snapshotChidDict = child.value as! NSDictionary
            guard let name = snapshotChidDict["name"] as? String, let profileImageURL = snapshotChidDict["profilePhotoURL"] as? String, let userID = snapshotChidDict["userID"] as? String, let location = snapshotChidDict["location"] as? String else { return }
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

    private func downloadUserProfileImage(_ URL: String, completion: @escaping ImageResult) {
        AlamoFireOperation.downloadProfileImageWithAlamoFire(URL: URL) {
            (image, error) in
            guard let image = image else {
                completion(nil, error)
                return
            }
            completion(image, nil)
        }
    }


    

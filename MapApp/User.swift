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
let imageCacher = ImageCacher()


struct User: UserType {
    var name: String
    var userID: String
    var profileImageURL: String
    var profileImage: UIImage?
  
    static func createUserWithFirebaseSnapshot(_ snapshot:FIRDataSnapshot, completion: @escaping UserResult) {
        let snapshotDict = snapshot.value as! NSDictionary
        for child in snapshotDict {
            let snapshotChildDict = child.value as! NSDictionary

            guard let name = snapshotChildDict["username"] as? String,
                let profileImageURL = snapshotChildDict["profileImageURL"] as? String,
                let userID = snapshotChildDict["userID"] as? String else {
                    print("\(snapshotChildDict["userID"])")
                    return }
                completion(User(name: name, userID: userID, profileImageURL: profileImageURL, profileImage: nil))
            }
        }
    
    }



    

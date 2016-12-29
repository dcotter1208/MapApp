//
//  CurrentUser.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase
import RealmSwift

class CurrentUser: UserType {
    var snapshotKey = ""
    var username = ""
    var profileImageURL = ""
    var userID = ""
    var profileImage: UIImage? = nil
    
    class var sharedInstance: CurrentUser {
        struct Singleton {
            static let instance = CurrentUser()
        }
        return Singleton.instance
    }

    func setCurrentUserProperties(_ username: String, imageURL: String, userID: String, snapshotKey: String) {
        self.username = username
        self.profileImageURL = imageURL
        self.userID = userID
        self.snapshotKey = snapshotKey
    }
    
    func resetProperties() {
        self.username = ""
        self.profileImageURL = ""
        self.userID = ""
        self.snapshotKey = ""
        self.profileImage = nil
    }
    
    func setCurrentUserWithRealm(results: Results<RLMUser>) {
        self.setCurrentUserProperties(results[0].username, imageURL: results[0].profileImageURL, userID: results[0].userID, snapshotKey: results[0].snapshotKey)
        guard results[0].profileImage != nil else {return}
        self.profileImage = UIImage(data: results[0].profileImage!)
    }
    
    func setCurrentUserWithFirebase(snapshot: FIRDataSnapshot) {
        let snapshotDict = snapshot.value as! NSDictionary

        for child in snapshotDict {
            let snapshotChildDict = child.value as! NSDictionary

            guard let
                username = snapshotChildDict["name"] as? String,
                let imageURL = snapshotChildDict["profileImageURL"] as? String,
                let userID = snapshotChildDict["userID"] as? String else {
                    return
            }
            self.username = username
            self.userID = userID
            self.profileImageURL = imageURL
        }
        guard self.profileImageURL != "" else {return}
        downloadUserProfileImage(self.profileImageURL)
    }
    
    fileprivate func downloadUserProfileImage(_ URL: String) {
        AlamoFireOperation.downloadProfileImageWithAlamoFire(URL: URL) {
            (image, error) in
            guard let image = image else {
                print(error as Any)
                return
            }
            self.profileImage = image
        }
    }

}

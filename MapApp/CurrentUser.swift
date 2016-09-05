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

class CurrentUser: User {
    var snapshotKey = ""
    
    //1
    class var sharedInstance: CurrentUser {
        //2
        struct Singleton {
            //3
            static let instance = CurrentUser()
        }
        //4
        return Singleton.instance
    }
    
    private override init() {
        super.init()
    }
    
    func setCurrentUserProperties(name: String, location: String, imageURL: String, userID: String, snapshotKey: String) {
        self.name = name
        self.location = location
        self.imageURL = imageURL
        self.userID = userID
        self.snapshotKey = snapshotKey
    }
    
    func resetProperties() {
        self.name = ""
        self.imageURL = ""
        self.userID = ""
        self.snapshotKey = ""
        self.location = ""
        self.profileImage = nil
    }
    
    func setCurrentUserWithRealm(results: Results<RLMUser>) {
        self.setCurrentUserProperties(results[0].name, location: results[0].location, imageURL: results[0].profileImageURL, userID: results[0].userID, snapshotKey: results[0].snapshotKey)
        guard results[0].profileImage != nil else {return}
        self.profileImage = UIImage(data: results[0].profileImage!)
    }
    
    func setCurrentUserWithFirebase(snapshot: FIRDataSnapshot) {
        for child in snapshot.children {
            guard let
                name = child.value["name"] as? String,
                imageURL = child.value["profileImageURL"] as? String,
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

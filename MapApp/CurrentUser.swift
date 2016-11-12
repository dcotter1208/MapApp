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
    var name = ""
    var location = ""
    var profileImageURL = ""
    var userID = ""
    var profileImage: UIImage? = nil
    
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

    func setCurrentUserProperties(_ name: String, location: String, imageURL: String, userID: String, snapshotKey: String) {
        self.name = name
        self.location = location
        self.profileImageURL = imageURL
        self.userID = userID
        self.snapshotKey = snapshotKey
    }
    
    func resetProperties() {
        self.name = ""
        self.profileImageURL = ""
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
        print("Snapshot: \(snapshot)")
        
        let snapshotDict = snapshot.value as! NSDictionary
        
        print("Snapshot Dict: \(snapshotDict)")

        
        for child in snapshotDict {
            let snapshotChildDict = child.value as! NSDictionary
            
            print("Snapshot Child Dict: \(snapshotChildDict)")

            
            guard let
                name = snapshotChildDict["name"] as? String,
                let imageURL = snapshotChildDict["profileImageURL"] as? String,
                let userID = snapshotChildDict["userID"] as? String,
                let location = snapshotChildDict["location"] as? String else {
                    return
            }
            self.name = name
            self.location = location
            self.userID = userID
            self.profileImageURL = imageURL
            
            print("Username set with Firebase:::: \(self.name)")
            
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

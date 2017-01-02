//
//  RLMUser.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import RealmSwift

class RLMUser: Object {
    dynamic var username = ""
    dynamic var profileImageURL = ""
    dynamic var userID = ""
    dynamic var botID = ""
    dynamic var snapshotKey = ""
    dynamic var profileImage: Data? = nil
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func createUser(userProfile: [String : AnyObject]) -> RLMUser? {
        if let username = userProfile["username"] as? String, let userID = userProfile["userID"] as? String, let botID = userProfile["botID"] as? String, let snapshotKey = userProfile["snapshotKey"] as? String {
            self.username = username
            self.userID = userID
            self.botID = botID
            self.snapshotKey = snapshotKey
            
            if let url = userProfile["profileImageURL"] as? String {
                self.profileImageURL = url
                if let image = userProfile["profileImage"] as? UIImage {
                    let data = image.convertToData()
                    self.profileImage = data
                }
            }
            return self
        } else {
            return nil
        }
    }

    func setRLMUserProfileImageAndURL(_ URL: String, image: Data) {
        self.profileImageURL = URL
        self.profileImage = image
    }
    
    
}

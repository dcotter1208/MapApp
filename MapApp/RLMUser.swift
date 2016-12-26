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
    dynamic var name = ""
    dynamic var profileImageURL = ""
    dynamic var userID = ""
    dynamic var snapshotKey = ""
    dynamic var profileImage: Data? = nil
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    func createUser(_ name: String, userID: String, snapshotKey: String) -> RLMUser {
        self.name = name
        self.userID = userID
        self.snapshotKey = snapshotKey
        return self
    }
    
    func setRLMUserProfileImageAndURL(_ URL: String, image: Data) {
        self.profileImageURL = URL
        self.profileImage = image
    }
    
    
}

//
//  CurrentUser.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit

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
    
    func setCurrentUserProperties(name: String, location: String, email: String, imageURL: String, userID: String, snapshotKey: String) {
        self.name = name
        self.location = location
        self.email = email
        self.imageURL = imageURL
        self.userID = userID
        self.snapshotKey = snapshotKey
    }
    
    func resetProperties() {
        self.name = ""
        self.email = ""
        self.imageURL = ""
        self.userID = ""
        self.snapshotKey = ""
        self.location = ""
        self.profileImage = nil
    }
    
}

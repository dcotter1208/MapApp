//
//  Message.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/21/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message {
    var message: String
    var timestamp: String
    var locationID: String
    var userID: String
    
    static func createMessageWithFirebaseData(snapshot: FIRDataSnapshot) -> Message {
        let messageSnapshot = snapshot.value as! NSDictionary
        let message = Message(message: messageSnapshot["message"] as! String, timestamp: messageSnapshot["timestamp"] as! String, locationID: messageSnapshot["locationID"] as! String, userID: messageSnapshot["userID"] as! String)
        return message
    }
    
}

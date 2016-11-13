//
//  Message.swift
//  MapApp
//
//  Created by Donovan Cotter on 10/21/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct Message: MessageProtocol {
    var text: String
    var timestamp: String
    var locationID: String
    var userID: String
    var mediaURL: String?
    
    static func createMessageWithFirebaseData(snapshot: FIRDataSnapshot) -> Message {
        let messageSnapshot = snapshot.value as! NSDictionary
        var message: Message
        
        print("SNAPSHOT: \(messageSnapshot)")
        
        if messageSnapshot["mediaURL"] == nil {
            message = Message(text: messageSnapshot["text"] as! String, timestamp: messageSnapshot["timestamp"] as! String, locationID: messageSnapshot["locationID"] as! String, userID: messageSnapshot["userID"] as! String, mediaURL: nil)
        } else {
            message = Message(text: messageSnapshot["text"] as! String, timestamp: messageSnapshot["timestamp"] as! String, locationID: messageSnapshot["locationID"] as! String, userID: messageSnapshot["userID"] as! String, mediaURL: messageSnapshot["mediaURL"] as? String)
        }
        return message
    }
    
}

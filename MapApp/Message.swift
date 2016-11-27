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
    var text: String?
    var timestamp: String
    var locationID: String
    var userID: String
    var mediaURL: String?
    var messageType: MessageType
    
    static func createMessageWithFirebaseData(snapshot: FIRDataSnapshot) -> Message {
        let messageSnapshot = snapshot.value as! NSDictionary
        var message: Message
        let messageType = mapMessageType(messageType: messageSnapshot["messageType"] as! String)
        
        switch messageType {
        case .text:
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: nil,
                              messageType: messageType)
            return message
        case .mediaText:
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: messageSnapshot["mediaURL"] as? String,
                              messageType: messageType)
            return message
        case .media:
            message = Message(text: nil,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: messageSnapshot["mediaURL"] as? String,
                              messageType: messageType)
            return message
        }
    }
    
    fileprivate static func mapMessageType(messageType: String) -> MessageType {
        switch messageType {
        case "text":
            return .text
        case "mediaText":
            return .mediaText
        case "media":
            return .media
        default:
            return .text
        }
    }
    
}

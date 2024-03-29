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
    var mediaOrientation: MediaOrientation?
    var messageType: MessageType
    
    static func createMessageWithFirebaseData(snapshot: FIRDataSnapshot) -> Message? {
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
                              mediaOrientation: nil,
                              messageType: messageType)
            return message
        case .media:
            
            var mediaOrientation: MediaOrientation
            
            guard let mediaTypeRawValue = messageSnapshot["mediaOrientation"] as? String else { return nil }

            switch mediaTypeRawValue {
            case MediaOrientation.portrait.rawValue:
                mediaOrientation = .portrait
            case MediaOrientation.landscape.rawValue:
                mediaOrientation = .landscape
            default:
                mediaOrientation = .portrait
            }
            
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: messageSnapshot["mediaURL"] as? String,
                              mediaOrientation: mediaOrientation,
                              messageType: messageType)
            return message
        }
    }
    
    fileprivate static func mapMessageType(messageType: String) -> MessageType {
        switch messageType {
        case "text":
            return .text
        case "media":
            return .media
        default:
            return .text
        }
    }
    
}

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
    var venues: [Venue]?
    
    static func createMessageWithFirebaseData(snapshot: FIRDataSnapshot) -> Message? {
        let messageSnapshot = snapshot.value as! NSDictionary
        var message: Message
        let messageType = mapMessageType(messageType: messageSnapshot["messageType"] as! String)
        
        switch messageType {
        case .userText:
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: nil,
                              mediaOrientation: nil,
                              messageType: messageType, venues: nil)
            return message
        case .userMedia:
            
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
                              messageType: messageType, venues: nil)
            return message
        
        case .botTextResponse:
            
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: nil,
                              mediaOrientation: nil,
                              messageType: messageType, venues: nil)
            
            return message
        
        case .botSearchResponse:
            
            message = Message(text: messageSnapshot["text"] as? String,
                              timestamp: messageSnapshot["timestamp"] as! String,
                              locationID: messageSnapshot["locationID"] as! String,
                              userID: messageSnapshot["userID"] as! String,
                              mediaURL: messageSnapshot["mediaURL"] as? String, //Will only have one URL for cell display.
                              mediaOrientation: nil,
                              messageType: messageType, venues: nil)
            
            return message
            
        }
        
    }
    
    fileprivate static func mapMessageType(messageType: String) -> MessageType {
        switch messageType {
        case "userText":
            return .userText
        case "userMedia":
            return .userMedia
        case "botTextResponse":
            return .botTextResponse
        case "botSearchResponse":
            return .botSearchResponse
        default:
            return .botTextResponse
        }
    }

}

//
//  MessageProtocol.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/12/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation

/* Unimplemented MessageType
 case mediaText
 */

enum MessageType: String {
    case text
    case media
}

enum MediaOrientation: String {
    case portrait
    case landscape
}

protocol MessageProtocol {
    var text: String? {get set}
    var timestamp: String {get set}
    var locationID: String {get set}
    var userID: String {get set}
    var mediaURL: String? {get set}
    var mediaOrientation: MediaOrientation? {get set}
    var messageType: MessageType {get set}
}

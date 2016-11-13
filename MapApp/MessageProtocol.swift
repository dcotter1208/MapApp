//
//  MessageProtocol.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/12/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation

protocol MessageProtocol {
    var text: String {get set}
    var timestamp: String {get set}
    var locationID: String {get set}
    var userID: String {get set}
    var mediaURL: String? {get set}
}

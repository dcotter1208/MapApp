//
//  Venue.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/17/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import MapKit

enum LocationType {
    case annotationDefault
    case bar
    case casino
    case sportsStadium
    case music
    case park
}

struct Venue {
    var name : String
    var phoneNumber: String
    var websiteURL: String
    var address: Address
    var coordinates: Coordinate
    var venueID: String {
        get {
            return "\(coordinates.lat)\(coordinates.long)"
        }
    }
}

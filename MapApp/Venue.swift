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
    case AnnotationDefault
    case Bar
    case Casino
    case SportsStadium
    case Music
    case Park
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
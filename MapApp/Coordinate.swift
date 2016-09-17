//
//  Coordinate.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/17/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import MapKit

struct Coordinate {
    var lat: Double
    var long: Double
    var coordinates: CLLocationCoordinate2D {
        get {
            return CLLocationCoordinate2D(latitude: lat, longitude: long)
        }
    }
    
    init(coordinate: CLLocationCoordinate2D) {
        self.lat = coordinate.latitude
        self.long = coordinate.longitude
    }
    
}
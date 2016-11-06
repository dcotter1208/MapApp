//
//  Marker.swift
//  MapApp
//
//  Created by Donovan Cotter on 11/6/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import GoogleMaps

class Marker: GMSMarker {
    var venueID: String
    
    init(venueID: String, markerPosition: CLLocationCoordinate2D) {
        self.venueID = venueID
        super.init()
        self.position = markerPosition
    }
    
}

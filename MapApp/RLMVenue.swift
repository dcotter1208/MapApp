//
//  RLMVenue.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/15/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation
import RealmSwift

class RLMVenue: Object {
    dynamic var name : String?
    dynamic var address: String?
    dynamic var lat: String?
    dynamic var long: String?
    dynamic var priceLevel: String?
    dynamic var googleRating: String?
    dynamic var isOpenNow: String?
    dynamic var phone: String?
    dynamic var website: String?
    var photos: List<RLMVenuePhoto>?
    dynamic var photoReference: String?
    dynamic var photoAttribution: String? //Try setting this as a link in a textview.
    dynamic var venueID: String?
    
    override static func primaryKey() -> String? {
        return "venueID"
    }
    
   func createVenue(venue: Venue) {
        //Similar to how a user is created, create a realm Venue. It will
        //accept either a Venue object or a dict to do this.
    //*****MUST CREATE A RLMVenuePhoto and Store in array of photos on RLMVenue.***///
    }
    
}

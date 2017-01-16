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
    dynamic var phone: String?
    dynamic var website: String?
    dynamic var priceLevel: String?
    dynamic var googleRating: String?
    dynamic var isOpenNow: String?
    var photos: List<RLMVenuePhoto>?
    dynamic var venueID: String?
    
    override static func primaryKey() -> String? {
        return "venueID"
    }
    
   func createVenues(venues: [Venue]) {
    constructRLMVenuePhotoList(venues: venues)
    let rlmVenues = List<RLMVenue>()
        for venue in venues {
            let rlmVenue = createRLMVenue(venue: venue)
            rlmVenues.append(rlmVenue)
        }
    RLMDBManager().batchWriteVenues(objects: rlmVenues)
    }

    fileprivate func createRLMVenue(venue: Venue) -> RLMVenue {
        let rlmVenue = RLMVenue()
        if  let name = venue.name,
            let address = venue.address.formattedAddress,
            let lat =  venue.coordinate?.lat,
            let long = venue.coordinate?.long,
            let venueID = venue.venueID {
            rlmVenue.name = name
            rlmVenue.venueID = venueID
            rlmVenue.address = address
            rlmVenue.lat = "\(lat)"
            rlmVenue.long = "\(long)"
        }

        if let phone = venue.contactInfo?.phone,
            let webURL = venue.contactInfo?.websiteURL {
            rlmVenue.phone = phone
            rlmVenue.website = webURL
        }
        
        if let priceLevel = venue.priceLevel {
            rlmVenue.priceLevel = "\(priceLevel)"
        }
        
        if let googleRating = venue.googleRating {
            rlmVenue.googleRating = "\(googleRating)"
        }
        
        if let isOpenNow = venue.isOpenNow {
            rlmVenue.isOpenNow = isOpenNow.stringValue()
        }
        
        return rlmVenue
    }
    
    
    fileprivate func constructRLMVenuePhotoList(venues: [Venue]) {
        let rlmVenuePhotos = List<RLMVenuePhoto>()
        for venue in venues {
            if let venueID = venue.venueID, let venuePhotos = venue.venuePhotos {
                for photo in venuePhotos {
                    let rlmVenuePhoto = RLMVenuePhoto().createPhoto(reference: photo.reference, attribution: photo.attribution, venueID: venueID)
                    rlmVenuePhotos.append(rlmVenuePhoto)
                }
            }
        }
        RLMDBManager().batchWriteVenuePhotos(objects: rlmVenuePhotos)
    }

}

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
    var address: Address
    var coordinate: Coordinate
    var priceLevel: Int?
    var googleRating: Double
    var isOpenNow: Bool
    var venueID: String
    var contactInfo: VenueContactInfo?
 
    
    static func getAllVenuesWithCoordinate(coordinate: CLLocationCoordinate2D) {
        AlamoFireOperation.googlePlacesCategoryTypeSearchForCoordinates(categoryType: .Bar, coordinate: coordinate) { (places, error) in
            guard error == nil else { return }
            var i = 0
            while i < places!.count {
                let venue = places![i]
                i += 1
                let name = venue["name"] as? String
                print("Venue Name: \(name)")
                let location = venue["geometry.location"] as? NSDictionary
                print("Venue Location: \(location)")

                let priceLevel = venue["price_level"] as? Int
                print("Venue Price Level: \(priceLevel)")

                let address = venue["formatted_address"] as? String
                print("Venue Address: \(address)")

                let openStatus = venue["opening_hours"] as? NSDictionary
                print("Venue Open Status: \(openStatus)")

                let rating = venue["rating"] as? Double
                print("Venue Rating: \(rating)")

                let placeID  = venue["place_id"] as? String
                print("Venue PlaceID: \(placeID)")

            }
        }
    }
    
}




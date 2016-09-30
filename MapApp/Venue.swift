//
//  Venue.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/17/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import MapKit

typealias NetworkResult = ([Venue]?, Error?) -> Void

enum VenueType: String {
    case annotationDefault
    //Drinks
    case DiveBars
    case Pubs
    case DanceClubs
    case JazzBar
    //Casinos
    case Casino
    //Music
    case Music
    case ConcertHall
    case Theatre
    //Sports
    case SportsStadium
    //Outdoors
    case Park
    case StatePark
    //Comedy
    case ComedyClub
}

struct Venue {
    var name : String?
    var address: Address
    var coordinate: Coordinate?
    var priceLevel: Int?
    var googleRating: Double?
    var isOpenNow: Bool?
    var venueID: String?
    var contactInfo: VenueContactInfo?
 
    
    static func getAllVenuesWithCoordinate(categoryType: GooglePlacesCategoryType, coordinate: CLLocationCoordinate2D, completion: @escaping NetworkResult) {
        var allVenues = [Venue]()
        AlamoFireOperation.googlePlacesCategoryTypeSearchForCoordinates(categoryType: categoryType, coordinate: coordinate) { (places, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            var i = 0
            while i < places!.count {
                let venue = places![i]
                i += 1
                guard let name = venue["name"] as? String else { continue }
                guard let location = venue["geometry"] as? NSDictionary else { continue }
                let coordinate = getCoordinatesFromLocationDict(locationDict: location)
                let priceLevel = venue["price_level"] as? Int
                let address = venue["formatted_address"] as? String
                let openingHours = venue["opening_hours"] as? [String: AnyObject]
                let openNowStatus = getOpenStatusFromOpeningHours(openingHours: openingHours)
                let rating = venue["rating"] as? Double
                let placeID  = venue["place_id"] as? String
                let newVenue = Venue(name: name, address: Address(formattedAddress: address), coordinate: coordinate, priceLevel: priceLevel, googleRating: rating, isOpenNow: openNowStatus, venueID: placeID!, contactInfo: nil)
                allVenues.append(newVenue)
                completion(allVenues, nil)
            }
        }
    }
    
    
    //USE THIS TO RETURN A COORDINATE FROM THE LOCATION RETURNED FROM GOOGLE
    static func getCoordinatesFromLocationDict(locationDict: NSDictionary?) -> Coordinate? {
        guard let locationDict = locationDict else { return nil }
            let lat = locationDict.value(forKeyPath: "location.lat")
            let long = locationDict.value(forKeyPath: "location.lng")
            let coordinate = Coordinate(coordinate: CLLocationCoordinate2D(latitude: lat as! Double, longitude: long as! Double))
            return coordinate
    }
    
    static func getOpenStatusFromOpeningHours(openingHours: [String: AnyObject]?) -> Bool? {
        guard openingHours != nil else { return nil }
        guard let openNowStatus = openingHours?["open_now"] as? Int else { return nil }

        switch openNowStatus {
        case 0:
            return false
        case 1:
            return true
        default:
            return nil
        }
    }

}


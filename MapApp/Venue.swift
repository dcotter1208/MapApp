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
    
    static func parseJSON(JSON: [NSDictionary]) {

        
        
        for venue in JSON {
            guard
                let name = venue["name"] as? String,
                let location = venue.value(forKeyPath: "geometry.location") as? NSDictionary,
                let priceLevel = venue["price_level"] as? Int,
                let address = venue["formatted_address"] as? String,
                let openStatus = venue["opening_hours"] as? NSDictionary,
                let rating = venue["rating"] as? Double,
                let placeID  = venue["place_id"] as? String
            else { continue }
            let venue = Venue(name: name, address: Address(formattedAddress: address) , coordinate: Coordinate(coordinate: CLLocationCoordinate2DMake(location["lat"] as! Double, location["lng"] as! Double)), priceLevel: priceLevel, googleRating: rating, isOpenNow: true, venueID: placeID, contactInfo: nil)
            print(venue)
        }
    }
    
    static func getAllVenuesWithCoordinate(coordinate: CLLocationCoordinate2D) {
        AlamoFireOperation.googlePlacesCategoryTypeSearchForCoordinates(categoryType: .Bar, coordinate: coordinate) {
            venueData, error in
            guard error == nil else {
                print("Google Place Search Error: \(error)")
                return
            }
            
            parseJSON(JSON: venueData!)
                
               /*
                 let priceLevel = venue["price_level"] as? String,
                 let address = venue["formatted_address"] as? String,
                 let openStatus = venue["opening_hours"] as? NSDictionary,
                 let rating = venue["rating"] as? Double,
                 let placeID  = venue["place_id"] as? String else {
                 
                 print("Something is wrong")
                 
                 return }
                 
                 print("Hey we made it here")
 */

                
               // print("OPEN STATUS: ******\(openStatus)******")
                
            
            }
        }
    }




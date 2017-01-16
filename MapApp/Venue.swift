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

struct Venue {
    var name : String?
    var address: Address
    var coordinate: Coordinate?
    var priceLevel: Int?
    var googleRating: Double?
    var isOpenNow: Bool?
    var venueID: String?
    var contactInfo: VenueContactInfo?
    var venuePhotos: [VenuePhoto]?
 
    static func getAllVenuesWithCoordinate(categoryType: GooglePlacesCategoryType?, searchText: String?, keyword: String?, coordinate: CLLocationCoordinate2D, searchType: SearchType,  completion: @escaping NetworkResult) {
        var allVenues = [Venue]()
        
        GoogleSearchAPI.googlePlacesSearch(categoryType: categoryType, searchText: searchText, keyword: keyword, coordinate: coordinate, searchType: searchType) { (places, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            var i = 0
            while i < places!.count {
                let venue = places![i]
                let typeArray = venue["types"] as! [String]
                i += 1
                if filterOutPlacesByType(categoryType: categoryType!, types: typeArray) == false {
                    guard let name = venue["name"] as? String else { continue }
                    guard let location = venue["geometry"] as? NSDictionary else { continue }
                    let coordinate = getCoordinatesFromLocationDict(locationDict: location)
                    let priceLevel = venue["price_level"] as? Int
                    let address = venue["formatted_address"] as? String
                    let openingHours = venue["opening_hours"] as? [String: AnyObject]
                    let openNowStatus = getOpenStatusFromOpeningHours(openingHours: openingHours)
                    let rating = venue["rating"] as? Double
                    let placeID  = venue["place_id"] as? String
                    let photos = venue["photos"] as? [[String: Any]]
                    let venuePhotos = constructVenuePhotoArray(photosArray: photos)
                    
                    let newVenue = Venue(name: name, address: Address(formattedAddress: address), coordinate: coordinate, priceLevel: priceLevel, googleRating: rating, isOpenNow: openNowStatus, venueID: placeID!, contactInfo: nil, venuePhotos: venuePhotos)
                    allVenues.append(newVenue)
                    if i == places?.count {
                        completion(allVenues, nil)
                    }
                }
            }
        }

}
    
    static fileprivate func constructVenuePhotoArray(photosArray: [[String: Any]]?) -> [VenuePhoto]? {
        guard let photos = photosArray else { return nil}
        var venuePhotos = [VenuePhoto]()
        
        for photo in photos {
            let photoRef = photo["photo_reference"] as? String
            let photoAttributionsArray = photo["html_attributions"] as? [String]
            guard let reference = photoRef else { return nil}
            var venuePhoto = VenuePhoto(reference: reference, attribution: nil, photoURLs: nil)
            
            if let attributions = photoAttributionsArray {
                venuePhoto.attribution = attributions.first
                venuePhotos.append(venuePhoto)
            } else {
                venuePhotos.append(venuePhoto)
            }
        }
        return venuePhotos
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
    
    static func filterOutPlacesByType(categoryType: GooglePlacesCategoryType, types: [String]) -> Bool {
        
        switch categoryType {
        case .Bar:
            return typesExists(type: "liquor_store", types: types)
        default:
            return false
        }
    }
    
    static func typesExists(type: String, types: [String]) -> Bool {
        if types.contains(type) {
            return true
        } else {
            return false
        }
    }
    
}

//
//  MKVenueSearch.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/17/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import MapKit

enum SearchTerm: String {
    case Default = "Fun"
    case Bar = "Bar"
    case DanceClub = "Dance Clubs"
    case DiveBar = "Dive Bar"
    case Drinks = "Drinks"
    case SportsBar = "Sports Bar"
    case Brewery = "Brewery"
    case Casino = "Casino"
    case Stadium = "Stadium"
    case Arena = "Arena"
    case ConcertVenue = "Concert Venues"
    case Theatre = "Performing Arts Theatre"
    case Park = "Park"
}

typealias LocalSearchResult = ([Venue] -> Void)

class MKVenueSearch {

   class func searchVenuesInRegion(searchRegion: MKCoordinateRegion, searchQueries:[SearchTerm], completion: LocalSearchResult) {
        let searchRequest = MKLocalSearchRequest()
        var MKLocalSearchTerm: SearchTerm
        
        var venues = [Venue]()
        
        for searchTerm in searchQueries {
            MKLocalSearchTerm = searchTerm
            searchRequest.naturalLanguageQuery = MKLocalSearchTerm.rawValue
            searchRequest.region = searchRegion
            let search = MKLocalSearch(request: searchRequest)
            
            search.startWithCompletionHandler({ (response, error) in
                guard let mapItems = response?.mapItems else { return }
                for item in mapItems {
                    guard let name = item.name, phoneNumber = item.phoneNumber, websiteURL = item.url else { return }
                    let venue = Venue(name: name, phoneNumber: phoneNumber, websiteURL: "\(websiteURL)", address: Address(placemark: item.placemark))
                    venues.append(venue)
                    dispatch_async(dispatch_get_main_queue(), { 
                        completion(venues)
                    })
                }
            })
        }
    }
    
}

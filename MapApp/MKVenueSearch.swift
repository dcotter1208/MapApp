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

typealias LocalSearchResult = (([Venue]) -> Void)

class MKVenueSearch {

   class func searchVenuesInRegion(_ searchRegion: MKCoordinateRegion, searchQueries:[SearchTerm], completion: @escaping LocalSearchResult) {
        let searchRequest = MKLocalSearchRequest()
        var MKLocalSearchTerm: SearchTerm
        var venues = [Venue]()
        for searchTerm in searchQueries {
            MKLocalSearchTerm = searchTerm
            searchRequest.naturalLanguageQuery = MKLocalSearchTerm.rawValue
            searchRequest.region = searchRegion
            let search = MKLocalSearch(request: searchRequest)
            
            search.start(completionHandler: { (response, error) in
                guard let mapItems = response?.mapItems else { return }
                for item in mapItems {
                    guard let name = item.name, let phoneNumber = item.phoneNumber, let websiteURL = item.url else { return }
                    let venue = Venue(name: name, phoneNumber: phoneNumber, websiteURL: "\(websiteURL)", address: Address(placemark: item.placemark), coordinates: Coordinate(coordinate: item.placemark.coordinate))
                    if !venues.contains(where: {$0.venueID == venue.venueID}) {
                        venues.append(venue)
                    }
                    DispatchQueue.main.async(execute: {
                        completion(venues)
                    })
                }
            })
        }
    }
    
   class func addVenueAnnotationsToMap(_ mapView: MKMapView, venues: [Venue]) {
        mapView.removeAnnotations(mapView.annotations)
        for venue in venues {
            let annotation = Annotation(title: venue.name, coordinate: venue.coordinates.coordinates)
            mapView.addAnnotation(annotation)
        }
    }
    
}

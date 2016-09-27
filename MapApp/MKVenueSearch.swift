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
    case Bars = "Bars"
    case DanceClubs = "Dance Clubs"
    case DiveBars = "Dive Bars"
    case Drinks = "Drinks"
    case SportsBars = "Sports Bars"
    case Breweries = "Breweries"
    
    
    case Pubs = "Pubs"
    case IrishPubs = "Irish Pubs"
    case DrinkingPubs = "Drinking Pubs"
    case Pub = "Pub"
    
    
    case Casinos = "Casinos"
    case Stadiums = "Stadiums"
    case Arenas = "Arenas"
    case ConcertVenue = "Concert Venues"
    case Theatre = "Performing Arts Theatres"
    case Park = "Parks"
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

            })
        }
    }
    
   class func addVenueAnnotationsToMap(_ mapView: MKMapView, venues: [Venue]) {
        mapView.removeAnnotations(mapView.annotations)
        for venue in venues {
            if let name = venue.name, let coordinate = venue.coordinate?.coordinate {
                let annotation = Annotation(title: name, coordinate: coordinate)
                mapView.addAnnotation(annotation)
            }
        }
    }
    
}

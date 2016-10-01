//
//  GoogleSearchAPI.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/29/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire

enum GooglePlacesCategoryType: String {
    case AmusementPark = "amusement_park"
    case Bar = "bar"
    case Campground = "campground"
    case Casino = "casino"
    case Lodging = "lodging"
    case Park = "park"
    case Restaurant = "restaurant"
    case ShoppingMall = "shopping_mall"
    case Stadium = "stadium"
    case University = "university"
    case POI = "point_of_interest"
}

enum SearchType {
    case NearbySearch
    case TextSearch
}

//DO A GOOGLE SEARCHTEXT FUNCTION WITH TYPE RESTRICTIONS//
//Example: bars that are type bar.
//Example: gambling, lodging, type casino


class GoogleSearchAPI {
    
    class func googlePlacesSearch(categoryType: GooglePlacesCategoryType?, searchText: String?, coordinate: CLLocationCoordinate2D, searchType: SearchType, completion: @escaping GooglePlacesNetworkResult) {

        let URL = createSearchURL(categoryType: categoryType, searchText: searchText, coordinate: coordinate, searchType: searchType)
        
        Alamofire.request(URL).responseJSON { (jsonResponse) in
            guard jsonResponse.result.isSuccess else {
                completion(nil, jsonResponse.result.error)
                return
            }
            
            do {
                guard let json = try JSONSerialization.jsonObject(with: jsonResponse.data!, options: .allowFragments) as? [String: AnyObject] else { return }
                guard let places = json["results"] as? [[String: AnyObject]] else { return }
                completion(places, nil)
            } catch {
                print("error serializing JSON: \(error)")
            }
        }
    }
    
    class func createSearchURL(categoryType: GooglePlacesCategoryType?, searchText: String?, coordinate: CLLocationCoordinate2D, searchType: SearchType) -> String {
        var URL = ""
        let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!)
        if let key = keys?["GooglePlaces"] as? String {
            switch searchType {
            case .NearbySearch:
                URL = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=1000&type=\(categoryType!.rawValue)&key=\(key)"
            case .TextSearch:
                URL = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=\(searchText!)&location=\(coordinate.latitude),\(coordinate.longitude)&type=\(categoryType!.rawValue)&key=\(key)"
            }
        }
        return URL
    }

    
}

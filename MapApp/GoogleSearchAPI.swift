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

//DO A GOOGLE SEARCHTEXT FUNCTION WITH TYPE RESTRICTIONS//
//Example: bars that are type bar.
//Example: gambling, lodging, type casino


class GoogleSearchAPI {
    class func googlePlacesCategoryTypeSearchWithCoordinates(categoryType: GooglePlacesCategoryType, coordinate: CLLocationCoordinate2D, completion: @escaping GooglePlacesNetworkResult) {
        let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!)
        guard let key = keys?["GooglePlaces"] as? String else { return }
        let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=1000&type=\(categoryType.rawValue)&key=\(key)"
        Alamofire.request(url).responseJSON { (jsonResponse) in
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
}

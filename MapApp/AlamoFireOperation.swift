//
//  AlamoFireOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireImage
import CoreLocation
import GooglePlaces

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
}

typealias ImageNetworkResult = (UIImage?, Error?) -> Void
typealias GooglePlacesNetworkResult = ([NSDictionary]?, Error?) -> Void

class AlamoFireOperation {
        
   class func downloadProfileImageWithAlamoFire(URL: String, completion: @escaping ImageNetworkResult) {
        Alamofire.request(URL)
            .responseImage { response in
                guard let image = response.result.value else {
                    if let error = response.result.error {
                        completion(nil, error)
                    }
                    return
                }
                completion(image, nil)
        }
    }
    
    class func googlePlacesCategoryTypeSearchForCoordinates(categoryType: GooglePlacesCategoryType, coordinate: CLLocationCoordinate2D, completion: @escaping GooglePlacesNetworkResult) {
       let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!)
    guard let key = keys?["GooglePlaces"] as? String else { return }
        
        let url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=pubs+bars&location=\(coordinate.latitude),\(coordinate.longitude)&radius=100&key=\(key)"

        Alamofire.request(url).responseJSON { (jsonResponse) in
            guard jsonResponse.result.isSuccess else {
                completion(nil, jsonResponse.result.error)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: jsonResponse.data!, options: .allowFragments) as? NSDictionary
                
                let results = json!["results"] as? [NSDictionary]
                
                for place in results! {
                    print("*************************************")
                    print(place)
                }
                
            } catch {
                print("error serializing JSON: \(error)")
            }
            
            let JSONDict = jsonResponse.result.value as? NSDictionary
            guard let venueArray = JSONDict?["results"] as? [NSDictionary] else { return }
            completion(venueArray, nil)
        }
    }
    
}


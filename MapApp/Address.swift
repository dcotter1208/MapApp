//
//  Address.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/17/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import MapKit

struct Address {
    var street: String?
    var city: String?
    var state: String?
    var countryCode: String?
    var zip: String?
    var fullAddress: String {
        get {
            guard let street = street, let city = city, let state = state, let countryCode = countryCode, let zip = zip else { return "" }
            return "\(street), \(city), \(state), \(countryCode), \(zip)"
        }
    }
    
    init(placemark: MKPlacemark) {
        guard let addressDictionary = placemark.addressDictionary else { return }
        self.street = addressDictionary["Street"] as? String
        self.city = addressDictionary["City"] as? String
        self.state = addressDictionary["State"] as? String
        self.countryCode = addressDictionary["CountryCode"] as? String
        self.zip = addressDictionary["ZIP"] as? String
    }
    
}

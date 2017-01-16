//
//  RLMVenuePhoto.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/15/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation
import RealmSwift

class RLMVenuePhoto: Object {
    dynamic var reference = ""
    dynamic var attribution: String? //Try setting this as a link in a textview.
    dynamic var venueID = ""
    
    override static func primaryKey() -> String? {
        return "venueID"
    }
    
    func createPhoto(reference: String, attribution: String?, venueID: String) -> RLMVenuePhoto {
    let rlmVenuePhoto = RLMVenuePhoto()
        rlmVenuePhoto.reference = reference
        rlmVenuePhoto.venueID = venueID
        if let safeAttribution = attribution {
            rlmVenuePhoto.attribution = safeAttribution
        }
    return rlmVenuePhoto
    }
    
}

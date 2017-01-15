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
    var reference = ""
    var attribution: String? //Try setting this as a link in a textview.
    
  func createPhoto(reference: String, attribution: String?) -> RLMVenuePhoto {
        self.reference = reference
        if let safeAttribution = attribution {
            self.attribution = safeAttribution
        }
    return self
    }
    
}

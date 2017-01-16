//
//  BotMessageFactory.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/15/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation
import Alamofire

fileprivate var photoRef = ""
fileprivate var maxWidth = ""
fileprivate let keys = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "Keys", ofType: "plist")!)


fileprivate var venuePhotoURL = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&photoreference=\(photoRef)&key="

class BotMessageFactory {
    
    func constructBotSearchResponseWithVenues(venues: [Venue]) {
        let botMessage = Message(text: "This should help \(CurrentUser.sharedInstance.username)", timestamp: "", locationID: "", userID: CurrentUser.sharedInstance.username, mediaURL: nil, mediaOrientation: nil, messageType: .botSearchResponse, venues: venues)
        
    }
    
    func getPhotoURLsForVenue(venues: [Venue]) {
        var references = [""]
        for venue in venues {
            if let venuePhotos = venue.venuePhotos {
                for photo in venuePhotos {
                    let reference = photo.reference
                    references.append(reference)
                }
            }
        }
        for reference in references {
            if let url = constructURLWithReference(reference: reference) {
            
                //MAKE CALL TO GET PHOTOS WITH ALAMOFIRE -> CURRENT TEST 
                //ON MAPVIEW IS fAIlING TO CONNECT WITH ALAMOFIRE.
                
                //a. Store photo urls in array and return in the 'getPhotoURLsForVenue' method
                //b. set the botMessage's venue's photo's photoURL property.
                //c. Send that Message to the [Message] on the ChatVC
            }
        }
    }
    
    fileprivate func constructURLWithReference(reference: String) -> String? {
        photoRef = reference
        maxWidth = "400"
        if let key = keys?["GooglePlaces"] as? String {
            return venuePhotoURL+key
        }
        return nil
    }
    
    

}

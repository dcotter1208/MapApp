//
//  Bot.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/2/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation
import CoreLocation

private let TooManySearchWordsResponse = "🤔 I couldn't find what you were looking for. Please Try rephrasing that."

//These are the keywords the bot will look for to perform a place search.
let searchCommands = ["search", "find", "locate"]
let searchKeywords = ["bars", "bar", "drinks", "drink", "sports bars", "club", "clubs", "beer", "brewery", "breweries", "restaurants", "restaurant", "food", "hungry", "eat"]

struct Bot  {
    var name = ""
    var botID = ""
    var userID = ""
    
    static func createBotWithUserID(userID: String) -> Bot {
        return Bot(name: "Bot", botID: UUID().uuidString, userID: userID)
    }
    
    func handleMessage(message: Message) {
        if message.messageType == .userMedia {
            //Response to media with "can't tell what that picture is"
        } else {
            respondToTextMessage(message: message)
        }
    }
    
    fileprivate func respondToTextMessage(message: Message) {
        let foundKeywords = filterTextForKeywords(text: message.text!)
        
        if foundKeywords.count == 0 {
            //Will Respond with a generic text message if there are no keywords.
            //Send to firebase
            return
        }
        
        if isSearchCommand(text: message.text!) {
            //Perform Search
            performSearchForKeywords(keywords: foundKeywords, completion: { (result, error) in
                guard let venues = result else {
                    print("ERROR: \(error)")
                    return
                }
                //Construct search result message
                self.constructSearchResultMessageWithVenues(venues: venues)
            })
        } else {
            //Respond to message with keywords but not search command.
            //Send to Firebase
        }
    
    }
    
    fileprivate func filterTextForKeywords(text: String) -> [String] {
        let lowercasedText = text.lowercased()
        var foundKeywords = [String]()
        
        for word in lowercasedText.components(separatedBy: " ") {
            if searchKeywords.contains(word) {
                foundKeywords.append(word)
            }
        }
        return foundKeywords
    }
    
    fileprivate func isSearchCommand(text: String) -> Bool {
            for searchKeyword in searchCommands {
                if text.contains(searchKeyword) {
                    return true
                }
            }
        return false
    }
    
    fileprivate func determineSearchType(foundKeywords: [String]) -> String? {
        //Check for more than 1 acceptable keyword
        if foundKeywords.count > 1 {
            return TooManySearchWordsResponse
        } else {
            return formatSearchKeyword(keyword: foundKeywords.first!)
        }
    }
    
    //if the user searches "best bars" then it'll turn that into "best+bars"
    fileprivate func formatSearchKeyword(keyword: String) -> String {
        return keyword.replacingOccurrences(of: " ", with: "+")
    }
    
    fileprivate func mapSearchTermToGooglePlacesCategoryType(searchTerm: String) -> GooglePlacesCategoryType {
        switch searchTerm {
        case "bars", "bar", "drinks", "drink", "sports bars", "club", "clubs", "beer", "brewery", "breweries":
            return .Bar
        case "restaurants", "restaurant", "food", "hungry", "eat":
            return .Restaurant
        default:
            return .Restaurant
        }
    }
    
    fileprivate func performSearchForKeywords(keywords: [String], completion: @escaping NetworkResult) {
        let searchTerm = determineSearchType(foundKeywords: keywords)
        guard let safeSearchTerm = searchTerm, let coordinate = LocationManager().getUserLocation() else { return }
        let searchCoordinates = CLLocationCoordinate2DMake(coordinate.coordinate.latitude, coordinate.coordinate.longitude)
        let googlePlaceCategoryType = mapSearchTermToGooglePlacesCategoryType(searchTerm: safeSearchTerm)
        
        Venue.getAllVenuesWithCoordinate(categoryType: googlePlaceCategoryType, searchText: safeSearchTerm, keyword: nil, coordinate: searchCoordinates, searchType: .TextSearch, completion: { (venues, error) in
            guard let foundPlaces = venues else {
                completion(nil, error)
                //Send Sorry Error Search Message
                print("BOT SEARCH ERROR: \(error)")
                return
            }
            completion(foundPlaces, nil)
        })
    }
    
    fileprivate func constructSearchResultMessageWithVenues(venues:[Venue]) {
        let venueIDs = extractVenueIDs(venues: venues)
        let message = ["text" : "I hope this helps: \(CurrentUser.sharedInstance.username)", "timestamp" : "", "locationID" : "123456789", "userID" : CurrentUser.sharedInstance.userID, "messageType": MessageType.botSearchResponse.rawValue, "venueIDs" : [venueIDs]] as [String : Any]
       FirebaseOperation().setValueForChild(child: "messages", value: message)
    }

    fileprivate func extractVenueIDs(venues: [Venue]) -> [String] {
        var venueIDs = [""]
        for venue in venues {
            if let safeVenueID = venue.venueID {
                venueIDs.append(safeVenueID)
            }
        }
        return venueIDs
    }
    
}


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

fileprivate var userLocationManager: CLLocationManager?
fileprivate var newestLocation = CLLocation()
fileprivate var userLocation: CLLocation?

struct Bot: CLLocationManagerDelegate, NSObjectProtocol {
    var name = ""
    var botID = ""
    var userID = ""
    
    static func createBotWithUserID(userID: String) -> Bot {
        return Bot(name: "Bot", botID: UUID().uuidString, userID: userID)
    }
    
    func handleMessage(message: Message) {
        if message.messageType == .media {
            //Response to media with "can't tell what that picture is"
        } else {
            respondToMessage(message: message)
        }
    }
    
    fileprivate func respondToMessage(message: Message) {
        //Will Respond with a generic text message and perform a search if its necessary.
    }
    
    fileprivate func filterTextForKeywords(text: String) {
        let lowercasedText = text.lowercased()
        var foundKeywords = [String]()
        
        for word in lowercasedText.components(separatedBy: " ") {
            if searchKeywords.contains(word) {
                foundKeywords.append(word)
            } else {
                //Non-Search related response
            }

            if isSearchCommand(text: text) {
                let searchTerm = determineSearchType(foundKeywords: foundKeywords)
                guard let safeSearchTerm = searchTerm, let coordinate = getUserLocation() else { return }
                let searchCoordinates = CLLocationCoordinate2DMake(coordinate.coordinate.latitude, coordinate.coordinate.longitude)
                let googlePlaceCategoryType = mapSearchTermToGooglePlacesCategoryType(searchTerm: safeSearchTerm)
                
                Venue.getAllVenuesWithCoordinate(categoryType: googlePlaceCategoryType, searchText: safeSearchTerm, keyword: nil, coordinate: searchCoordinates, searchType: .TextSearch, completion: { (venues, error) in
                    guard let foundPlaces = venues else {
                        //Send Sorry Error Search Message
                        print("BOT SEARCH ERROR: \(error)")
                    }
                    print("\(foundPlaces)")
                })
            } else {
                //Non-Search related response
            }
        }
        
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

    func getUserLocation() -> CLLocation? {
        userLocationManager = CLLocationManager()
        guard let manager = userLocationManager else { return nil }
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        manager.requestWhenInUseAuthorization()
        manager.distanceFilter = 100
        manager.startUpdatingLocation()
        guard let managerLocation = manager.location else { return nil }
        newestLocation = managerLocation
        return newestLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let lastLocation = locations.last else { return }
        newestLocation = lastLocation
        userLocation = newestLocation
    }

}


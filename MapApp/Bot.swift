//
//  Bot.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/2/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation

let keywords = ["search", "find", "locate", "bars", "bar", "drinks", "restaurants", "restaurant", "food", "movie", "movie theatre", "parks", "park",  "bowling", "arena", "sports", "hotels", "shopping",  "college",  "university", "universities"]

struct Bot {
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
        
    }
    
    fileprivate func filterTextForKeywords(text: String) {
        let lowercasedText = text.lowercased()
        var foundKeywords = [String]()
        
        for word in lowercasedText.components(separatedBy: " ") {
            if keywords.contains(word) {
                foundKeywords.append(word)
            } else {
                //Non-Search related response
            }

            if isSearchCommand(foundKeywords: foundKeywords) {
                
            } else {
                //Non-Search related response
            }
        }
        
    }
    
    fileprivate func isSearchCommand(foundKeywords: [String]) -> Bool {
        if foundKeywords.count >= 2 {
            for searchKeyword in foundKeywords {
                if searchKeyword == "search" || searchKeyword == "find" || searchKeyword == "locate" {
                    return true
                }
            }
        }
        return false
    }
    
    fileprivate func determineSearchType(foundKeywords: [String]) -> String? {
        let acceptableSearchTerms = ["bars", "bar", "drinks", "restaurants", "restaurant", "food", "movie", "movie theatre", "parks", "park",  "bowling", "arena", "sports", "hotels", "shopping",  "college",  "university", "universities"]
        
        for keyword in foundKeywords {
            if acceptableSearchTerms.contains(keyword) {
                //switchFoundKeyword
            }
        }
    }
    
    fileprivate func switchFoundKeyword(keyword: String) -> String? {
        //Switch on the keyword to determine which type of search will be performed. (Bar, restaurant, etc.)
    }
    
    
    //Will also need a way to determine a search result for someone typing in "bars in detroit, restaurants in new york, etc."

}


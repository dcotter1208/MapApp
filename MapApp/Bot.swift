//
//  Bot.swift
//  MapApp
//
//  Created by Donovan Cotter on 1/2/17.
//  Copyright © 2017 DonovanCotter. All rights reserved.
//

import Foundation

struct Bot {
    var name = ""
    var botID = ""
    var userID = ""
    
    static func createBot() -> Bot {
        return Bot(name: "Bot", botID: UUID().uuidString, userID: CurrentUser.sharedInstance.userID)
    }
    
}


//
//  RLMManager.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/3/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import RealmSwift

struct RLMDBManager {
    
    var realm: Realm?
    
    init() {
        do {
            realm = try Realm()
        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func writeObject(object:Object) {
        realm?.beginWrite()
        realm?.add(object)
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func updateObject(object:Object) {
        realm?.beginWrite()
        realm?.add(object, update: true)
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getCurrentUserFromRealm(userID:String) -> Results<RLMUser> {
        let user = realm?.objects(RLMUser.self).filter("userID = '\(userID)'")
        return user!
    }
    
    
}


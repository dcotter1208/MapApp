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
            print("realm**: \(realm?.configuration.fileURL)")

        } catch let error as NSError {
            print(error)
        }
        
    }
    
    func writeObject(_ object:Object) {
        realm?.beginWrite()
        realm?.add(object)
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func updateObject(_ object:Object) {
        realm?.beginWrite()
        realm?.add(object, update: true)
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func batchWriteVenues(objects: List<RLMVenue>) {
        realm?.beginWrite()
        for object in objects {
            realm?.add(object, update: true)
        }
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func batchWriteVenuePhotos(objects: List<RLMVenuePhoto>) {
        realm?.beginWrite()
        for object in objects {
            realm?.add(object, update: true)
        }
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func updateUserProfile(_ object:Object) {
        realm?.beginWrite()
        realm?.add(object, update: true)
        self.getCurrentUserProfileFromRealm()
        do {
            try realm?.commitWrite()
        } catch let error as NSError {
            print(error)
        }
    }
    
    func getRealmObjects(objectType: Object.Type) -> Results<Object>? {
        let realmResults = realm?.objects(objectType)
        if let results = realmResults {
            return results
        } else {
            return nil
        }
    }
    
    func getCurrentUserProfileFromRealm() {
        let realmResults = realm?.objects(RLMUser.self)
        if let results = realmResults {
            if results.count > 0 {
                CurrentUser.sharedInstance.setCurrentUserWithRealm(results: results)
            }
        }
    }
    
}


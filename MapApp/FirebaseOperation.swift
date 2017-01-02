//
//  FirebaseOperation.swift
//  MapApp
//
//  Created by Donovan Cotter on 9/2/16.
//  Copyright © 2016 DonovanCotter. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift
import Cloudinary
import FirebaseDatabase
import Firebase
import FirebaseAuth

enum AddOrUpdate: String {
    case add
    case update
}

typealias FirebaseProfileCreatedCompletion = (String?, String?) -> Void
typealias SignUpResult = (NSError?) -> Void
typealias LogInResult = (CurrentUser?, NSError?) -> Void
typealias CurrentUserResult = (CurrentUser) -> Void
typealias SnapshotExistsResult = (Bool) -> Void

class FirebaseOperation: NSObject, CLUploaderDelegate {
    
    let firebaseDatabaseRef = FIRDatabase.database().reference()

    //gets the snapshot key from a firebase reference.
    func getSnapshotKeyFromRef(firebaseChildRef: FIRDatabaseReference) -> String {
        let snapshotKey = "\(firebaseChildRef)".replacingOccurrences(of: "https://mapapp-943f3.firebaseio.com/users/", with: "")
        return snapshotKey
    }

    func addOrUpdateUserProfile(userProfile: [String: AnyObject], completion: FirebaseProfileCreatedCompletion) {
        var snapshotKey = ""
        var addOrUpdate: AddOrUpdate = .add
        if CurrentUser.sharedInstance.snapshotKey != "" {
            snapshotKey = CurrentUser.sharedInstance.snapshotKey
            addOrUpdate = .update
        }

        var firebaseProfile = userProfile
        firebaseProfile.removeValue(forKey: "profileImage")
        
        switch addOrUpdate {
        case .add:
            let newBot = Bot.createBot()
            writeBotToFirebase(bot: newBot)
            
            firebaseProfile["botID"] = newBot.botID as AnyObject?
            
            let usersRef = firebaseDatabaseRef.ref.child("users").childByAutoId()
            usersRef.setValue(firebaseProfile)
            completion(getSnapshotKeyFromRef(firebaseChildRef: usersRef), newBot.botID)
        case .update:
            self.updateChildValue(child: "users", childKey: snapshotKey, nodeToUpdate: firebaseProfile as [String : AnyObject])
            var newUserProfile = userProfile
            newUserProfile.updateValue(snapshotKey as AnyObject, forKey: "snapshotKey")
            newUserProfile.updateValue(CurrentUser.sharedInstance.botID as AnyObject, forKey: "botID")

            if let rlmUser = RLMUser().createUser(userProfile: newUserProfile) {
                    RLMDBManager().updateObject(rlmUser)
            }
        }
    }
    
    fileprivate func writeBotToFirebase(bot: Bot) {
        let botsRef = firebaseDatabaseRef.ref.child("bots").childByAutoId()
        let botProfile = ["name" : bot.name, "botID" : bot.botID, "userID" : bot.userID]
        botsRef.setValue(botProfile)
    }

    fileprivate func writeToRealm(userProfile: [String : AnyObject]) {
        if let realmUser = RLMUser().createUser(userProfile: userProfile) {
            RLMDBManager().writeObject(realmUser)
        }
    }
    
    //Creates a new value for a specified child
    func setValueForChild(child: String, value: [String: Any]) {
        let childRef = firebaseDatabaseRef.child(child).childByAutoId()
        childRef.setValue(value)
    }
    
    //Deletes a value for a specified child.
    func deleteValueForChild(child: String, childKey: String) {
        let childToRemove = firebaseDatabaseRef.child(child).child(childKey)
        childToRemove.removeValue()
    }
    
    //Updates a specified child node
    func updateChildValue(child: String, childKey:String, nodeToUpdate: [String: AnyObject]) {
        let childRef = firebaseDatabaseRef.child(child)
        let childUpdates = [childKey:nodeToUpdate]
        childRef.updateChildValues(childUpdates)
    }
    
    //queries a Firebase child without constraints.
    func queryChildWithoutConstraints(child: String, firebaseDataEventType: FIRDataEventType, completion: @escaping (_ result: FIRDataSnapshot) -> Void) {
        let childRef = firebaseDatabaseRef.child(child)
        childRef.observe(firebaseDataEventType) {
            (snapshot) in
            completion(snapshot)
        }
    }
    
    //Accepts a query to listen for a change.
    func listenForChildNodeChanges(query: FIRDatabaseQuery, completion:@escaping (_ result:FIRDataSnapshot)-> Void) {
        query.observe(FIRDataEventType.childChanged) {
            (snapshot) in
            completion(snapshot)
        }
    }
    
    //Accepts a query with contraints to query Firebase
    func queryChildWithConstraints(_ query:FIRDatabaseQuery, firebaseDataEventType: FIRDataEventType, observeSingleEventType: Bool, completion:@escaping (_ result: FIRDataSnapshot) -> Void) {
        if observeSingleEventType {
            query.observeSingleEvent(of: firebaseDataEventType, with: { (snapshot) in
                completion(snapshot)
            })
        } else {
            query.observe(firebaseDataEventType, with: { (snapshot) in
                completion(snapshot)
            })
        }
    }
    
     //Validates if the venue exists on Firebase.
    func validateVenueUniqueness(_ venue: Venue, completion: @escaping SnapshotExistsResult) {
        let query = firebaseDatabaseRef.ref.child("venues").queryOrdered(byChild: "venueID").queryEqual(toValue: venue.venueID)
        queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) { (snapshot) in
            if snapshot.exists() {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    //Validates if the venue exists on Firebase.
    func validateFirebaseChildUniqueness(child: String, queryOrderedBy: String, equaledTo: String, completion: @escaping SnapshotExistsResult) {
        let query = firebaseDatabaseRef.ref.child(child).queryOrdered(byChild: queryOrderedBy).queryEqual(toValue: equaledTo)
        queryChildWithConstraints(query, firebaseDataEventType: .value, observeSingleEventType: true) { (snapshot) in
            if snapshot.exists() {
            let username = self.getSnapshotChildValueForKey(snapshot: snapshot, key: "username")
                if let existingUsername = username {
                    if self.lowerCaseStringsMatch(string1: existingUsername, string2: equaledTo) {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            } else {
                completion(true)
            }
        }
    }

    func getSnapshotChildValueForKey(snapshot: FIRDataSnapshot, key: String) -> String? {
        var value = ""
        for childSnap in snapshot.children {
            let snap = childSnap as! FIRDataSnapshot
            if let snapshotValue = snapshot.value as? NSDictionary, let snapVal = snapshotValue[snap.key] as? NSDictionary {
                value = snapVal[key] as! String
                return value
            }
        }
        return nil
    }
    
    func lowerCaseStringsMatch (string1: String, string2: String) -> Bool {
        if string1.lowercased() == string2.lowercased() {
            return true
        } else {
            return false
        }
    }

    //MARK: Login & Signup Methods
    
    //Logs user into the app as an anonymous user.
    
    func loginWithAnonymousUser() {
        FIRAuth.auth()?.signInAnonymously(completion: { (user, error) in
            if error != nil {
                print("Anonymous Log In Error: \(error)")
            } else {
                print("TODO: create function to set the Current User Singleton for anonymous user")
                CurrentUser.sharedInstance.userID = user!.uid
            }
        })
    }

    //Sets the CurrentUser singleton with realm results.
    fileprivate func setCurrentUserWithRealm(_ results: Results<RLMUser>, completion:(CurrentUserResult)) {
        CurrentUser.sharedInstance.setCurrentUserWithRealm(results: results)
        completion(CurrentUser.sharedInstance)
    }
    
}
